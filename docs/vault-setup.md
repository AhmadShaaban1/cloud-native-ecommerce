# 🔐 HashiCorp Vault Setup Guide

## Overview

Vault provides secure secrets management for the e-commerce platform.

## Architecture
```
Application Pods
      ↓
Vault Agent Injector (sidecar)
      ↓
Vault Server (HA - 3 replicas)
      ↓
Kubernetes Auth Backend
      ↓
Secrets (KV v2 engine)
```

## Installation

### Automated Setup
```bash
# Deploy Vault
helm install vault hashicorp/vault \
  --namespace vault \
  --create-namespace \
  --values k8s/vault/vault-values.yaml

# Initialize and configure
./scripts/vault-setup.sh
```

### Manual Setup

#### 1. Initialize Vault
```bash
kubectl exec -n vault vault-0 -- vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  -format=json > vault-keys.json
```

**IMPORTANT**: Save `vault-keys.json` securely!

#### 2. Unseal Vault

You need 3 out of 5 unseal keys:
```bash
# Extract keys
UNSEAL_KEY_1=$(cat vault-keys.json | jq -r ".unseal_keys_b64[0]")
UNSEAL_KEY_2=$(cat vault-keys.json | jq -r ".unseal_keys_b64[1]")
UNSEAL_KEY_3=$(cat vault-keys.json | jq -r ".unseal_keys_b64[2]")
ROOT_TOKEN=$(cat vault-keys.json | jq -r ".root_token")

# Unseal each replica
for i in 0 1 2; do
  kubectl exec -n vault vault-$i -- vault operator unseal $UNSEAL_KEY_1
  kubectl exec -n vault vault-$i -- vault operator unseal $UNSEAL_KEY_2
  kubectl exec -n vault vault-$i -- vault operator unseal $UNSEAL_KEY_3
done
```

#### 3. Configure Kubernetes Auth
```bash
# Login to Vault
kubectl exec -n vault vault-0 -- vault login $ROOT_TOKEN

# Enable Kubernetes auth
kubectl exec -n vault vault-0 -- vault auth enable kubernetes

# Configure
kubectl exec -n vault vault-0 -- sh -c '
vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
'
```

#### 4. Enable Secrets Engine
```bash
kubectl exec -n vault vault-0 -- vault secrets enable -path=secret kv-v2
```

#### 5. Create Secrets
```bash
# MongoDB credentials
kubectl exec -n vault vault-0 -- vault kv put secret/ecommerce/mongodb \
  username=admin \
  password=SecureMongoPassword123!

# JWT secret
kubectl exec -n vault vault-0 -- vault kv put secret/ecommerce/jwt \
  secret=super-secure-jwt-secret-key-production-2024

# Redis password
kubectl exec -n vault vault-0 -- vault kv put secret/ecommerce/redis \
  password=SecureRedisPassword123!
```

#### 6. Create Policy
```bash
kubectl exec -n vault vault-0 -- vault policy write ecommerce-policy - <<EOF
path "secret/data/ecommerce/*" {
  capabilities = ["read", "list"]
}
EOF
```

#### 7. Create Kubernetes Role
```bash
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/ecommerce \
  bound_service_account_names=backend-service-account \
  bound_service_account_namespaces=default \
  policies=ecommerce-policy \
  ttl=24h
```

## Using Vault in Applications

### Method 1: Vault Agent Injector (Recommended)

Add annotations to your deployment:
```yaml
metadata:
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "ecommerce"
    vault.hashicorp.com/agent-inject-secret-mongodb: "secret/data/ecommerce/mongodb"
```

Secrets will be available at: `/vault/secrets/mongodb`

### Method 2: API Integration

See `services/user-service/src/server.js` for example.

## Operations

### Check Vault Status
```bash
kubectl exec -n vault vault-0 -- vault status
```

### Unseal After Restart

Vault pods will be sealed after restart. Use:
```bash
./scripts/vault-setup.sh
```

Or unseal manually with your keys.

### Rotate Secrets
```bash
# Update secret
kubectl exec -n vault vault-0 -- vault kv put secret/ecommerce/mongodb \
  username=admin \
  password=NewSecurePassword456!

# Restart pods to pick up new secret
kubectl rollout restart deployment user-service
```

### Access Vault UI
```bash
kubectl port-forward svc/vault-ui -n vault 8200:8200

# Open: http://localhost:8200
# Login with root token
```

## Backup and Recovery

### Backup
```bash
# Take snapshot
kubectl exec -n vault vault-0 -- vault operator raft snapshot save backup.snap

# Copy snapshot
kubectl cp vault/vault-0:backup.snap ./vault-backup-$(date +%Y%m%d).snap
```

### Restore
```bash
# Copy snapshot to pod
kubectl cp ./vault-backup.snap vault/vault-0:restore.snap

# Restore
kubectl exec -n vault vault-0 -- vault operator raft snapshot restore restore.snap
```

## Troubleshooting

### Vault Sealed

**Symptom**: Pods show "Vault is sealed"

**Solution**: Run unseal commands (see above)

### Cannot Authenticate

**Symptom**: Applications can't get secrets

**Solution**: 
1. Check service account exists: `kubectl get sa backend-service-account`
2. Verify role: `kubectl exec -n vault vault-0 -- vault read auth/kubernetes/role/ecommerce`
3. Check pod annotations

### Secrets Not Updating

**Symptom**: Old secret values after rotation

**Solution**: Restart deployment: `kubectl rollout restart deployment <name>`

## Security Best Practices

✅ Never commit `vault-keys.json` to git
✅ Store unseal keys in separate secure locations
✅ Use different root tokens for dev/prod
✅ Rotate secrets regularly
✅ Enable audit logging
✅ Use namespaced secrets
✅ Implement secret versioning

## References

- [Vault Documentation](https://www.vaultproject.io/docs)
- [Vault on Kubernetes](https://www.vaultproject.io/docs/platform/k8s)
- [Vault Agent Injector](https://www.vaultproject.io/docs/platform/k8s/injector)