# Kubernetes Version Management

## Current Version
- **Cluster**: 1.32
- **Upgraded from**: 1.30

## API Deprecations Observed

### v1.32 Changes
- **FlowSchema**: `flowcontrol.apiserver.k8s.io/v1beta3` → `v1` (GA)
- **Impact**: None on application workloads
- **Action**: No changes needed - cluster components handle this

## API Versions Used in Project

| Resource | API Version | Status |
|----------|-------------|--------|
| Deployment | apps/v1 | ✅ Stable |
| Service | v1 | ✅ Stable |
| ConfigMap | v1 | ✅ Stable |
| Secret | v1 | ✅ Stable |
| Ingress | networking.k8s.io/v1 | ✅ Stable |

## Upgrade Strategy

1. Test in dev environment first
2. Review deprecation warnings
3. Update manifests if needed
4. Rolling update to minimize downtime

## Future Deprecations to Watch

Check before upgrading:
```bash
kubectl get --raw /openapi/v2 | jq '.paths | keys[]' | grep -i deprecated
```

## References
- [Kubernetes Deprecation Policy](https://kubernetes.io/docs/reference/using-api/deprecation-policy/)
- [API Migration Guide](https://kubernetes.io/docs/reference/using-api/deprecation-guide/)