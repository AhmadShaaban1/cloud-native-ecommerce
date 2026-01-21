#!/bin/bash

set -e

echo "=========================================="
echo "🔐 HashiCorp Vault Setup"
echo "=========================================="
echo ""

# Check if Vault is running
if ! kubectl get pods -n vault | grep -q vault-0; then
    echo "❌ Vault is not installed. Run deploy-complete-stack.sh first."
    exit 1
fi

echo "🔍 Checking Vault status..."

# Check if already initialized
VAULT_STATUS=$(kubectl exec -n vault vault-0 -- vault status -format=json 2>/dev/null || echo '{"initialized":false}')
INITIALIZED=$(echo $VAULT_STATUS | jq -r '.initialized')

if [ "$INITIALIZED" = "true" ]; then
    echo "⚠️  Vault is already initialized."
    echo ""
    read -p "Do you want to unseal Vault? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Please enter your unseal keys (you need 3):"
        read -p "Unseal Key 1: " KEY1
        read -p "Unseal Key 2: " KEY2
        read -p "Unseal Key 3: " KEY3
        
        kubectl exec -n vault vault-0 -- vault operator unseal $KEY1
        kubectl exec -n vault vault-0 -- vault operator unseal $KEY2
        kubectl exec -n vault vault-0 -- vault operator unseal $KEY3
        
        echo "✅ Vault-0 unsealed"
        
        # Unseal other replicas
        kubectl exec -n vault vault-1 -- vault operator unseal $KEY1
        kubectl exec -n vault vault-1 -- vault operator unseal $KEY2
        kubectl exec -n vault vault-1 -- vault operator unseal $KEY3
        echo "✅ Vault-1 unsealed"
        
        kubectl exec -n vault vault-2 -- vault operator unseal $KEY1
        kubectl exec -n vault vault-2 -- vault operator unseal $KEY2
        kubectl exec -n vault vault-2 -- vault operator unseal $KEY3
        echo "✅ Vault-2 unsealed"
    fi
    exit 0
fi

echo "📝 Initializing Vault..."

# Initialize Vault
kubectl exec -n vault vault-0 -- vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  -format=json > vault-keys.json

echo "✅ Vault initialized"
echo ""
echo "⚠️  IMPORTANT: vault-keys.json has been created with your unseal keys and root token"
echo "    Store this file in a secure location (e.g., password manager, secrets vault)"
echo "    You will need these keys to unseal Vault after restarts"
echo ""

# Extract keys
UNSEAL_KEY_1=$(cat vault-keys.json | jq -r ".unseal_keys_b64[0]")
UNSEAL_KEY_2=$(cat vault-keys.json | jq -r ".unseal_keys_b64[1]")
UNSEAL_KEY_3=$(cat vault-keys.json | jq -r ".unseal_keys_b64[2]")
ROOT_TOKEN=$(cat vault-keys.json | jq -r ".root_token")

echo "🔓 Unsealing Vault..."

# Unseal vault-0
kubectl exec -n vault vault-0 -- vault operator unseal $UNSEAL_KEY_1
kubectl exec -n vault vault-0 -- vault operator unseal $UNSEAL_KEY_2
kubectl exec -n vault vault-0 -- vault operator unseal $UNSEAL_KEY_3
echo "✅ Vault-0 unsealed"

# Unseal vault-1
kubectl exec -n vault vault-1 -- vault operator unseal $UNSEAL_KEY_1
kubectl exec -n vault vault-1 -- vault operator unseal $UNSEAL_KEY_2
kubectl exec -n vault vault-1 -- vault operator unseal $UNSEAL_KEY_3
echo "✅ Vault-1 unsealed"

# Unseal vault-2
kubectl exec -n vault vault-2 -- vault operator unseal $UNSEAL_KEY_1
kubectl exec -n vault vault-2 -- vault operator unseal $UNSEAL_KEY_2
kubectl exec -n vault vault-2 -- vault operator unseal $UNSEAL_KEY_3
echo "✅ Vault-2 unsealed"

echo ""
echo "🔧 Configuring Vault..."

# Login
kubectl exec -n vault vault-0 -- vault login $ROOT_TOKEN

# Enable Kubernetes auth
kubectl exec -n vault vault-0 -- vault auth enable kubernetes

# Configure Kubernetes auth
kubectl exec -n vault vault-0 -- sh -c '
vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
'

# Enable KV v2 secrets engine
kubectl exec -n vault vault-0 -- vault secrets enable -path=secret kv-v2

echo "✅ Kubernetes auth configured"

echo ""
echo "🔑 Creating application secrets..."

# Create secrets
kubectl exec -n vault vault-0 -- vault kv put secret/ecommerce/mongodb \
  username=admin \
  password=SecureMongoPassword123!

kubectl exec -n vault vault-0 -- vault kv put secret/ecommerce/jwt \
  secret=super-secure-jwt-secret-key-production-2024

kubectl exec -n vault vault-0 -- vault kv put secret/ecommerce/redis \
  password=SecureRedisPassword123!

echo "✅ Secrets created"

echo ""
echo "📋 Creating policies..."

# Create policy
kubectl exec -n vault vault-0 -- vault policy write ecommerce-policy - <<EOF
path "secret/data/ecommerce/*" {
  capabilities = ["read", "list"]
}
EOF

# Create Kubernetes role
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/ecommerce \
  bound_service_account_names=backend-service-account \
  bound_service_account_namespaces=default \
  policies=ecommerce-policy \
  ttl=24h

echo "✅ Policies configured"

echo ""
echo "=========================================="
echo "✅ Vault Setup Complete!"
echo "=========================================="
echo ""
echo "📝 Summary:"
echo "   Root Token: $ROOT_TOKEN"
echo "   Unseal Keys: Check vault-keys.json"
echo ""
echo "🔒 Secure vault-keys.json:"
echo "   1. Copy to password manager"
echo "   2. Store in encrypted backup"
echo "   3. Delete from disk: rm vault-keys.json"
echo ""
echo "🌐 Access Vault UI:"
echo "   kubectl port-forward svc/vault-ui -n vault 8200:8200"
echo "   Then open: http://localhost:8200"
echo "   Login with root token: $ROOT_TOKEN"
echo ""