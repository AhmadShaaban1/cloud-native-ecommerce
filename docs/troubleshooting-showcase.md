# Troubleshooting Showcase - Real-World DevOps Skills

## Challenge 1: Terraform State Recovery
**Problem**: Accidentally deleted `main.tf` file during development

**Solution Steps**:
1. Used `git log` to find last commit with `main.tf`
2. Viewed file content: `git show <commit-hash>:terraform/environments/dev/main.tf`
3. Recreated file with correct configuration
4. Validated with `terraform plan`
5. Successfully applied configuration

**Skills Demonstrated**:
- Git version control mastery
- Terraform state management
- Recovery from production incidents
- Staying calm under pressure

**Outcome**: ✅ Infrastructure recovered without data loss

---

## Challenge 2: EKS Node Capacity Planning
**Problem**: External Secrets Operator pods stuck in Pending state

**Investigation**:
```bash
kubectl describe pod <pod-name> -n external-secrets-system
```

**Root Cause**: 
- Initial 4 nodes insufficient for full stack
- Memory pressure on nodes (>85%)
- No available resources for new pods

**Solution**:
```bash
# Scaled from 4 to 6 nodes
aws eks update-nodegroup-config \
  --cluster-name ecommerce-dev \
  --nodegroup-name ecommerce-dev-node-group \
  --scaling-config desiredSize=6

# Then to 8 nodes for complete stack
aws eks update-nodegroup-config \
  --cluster-name ecommerce-dev \
  --nodegroup-name ecommerce-dev-node-group \
  --scaling-config desiredSize=8
```

**Skills Demonstrated**:
- Kubernetes resource management
- Capacity planning
- Pod scheduling troubleshooting
- AWS EKS auto-scaling configuration

**Outcome**: ✅ All pods running successfully on 8-node cluster

---

## Challenge 3: Loki Deployment Mode Issues
**Problem**: Loki deployed in distributed mode with unwanted canary/cache pods

**Investigation**:
```bash
kubectl get pods -n monitoring | grep loki
# Saw: loki-canary, loki-chunks-cache, loki-results-cache
```

**Root Cause**:
- Helm values not properly applied
- Default deployment mode was distributed
- Resource-heavy components enabled

**Solution**:
1. Created minimal loki-values.yaml with explicit settings
2. Added explicit Helm overrides:
```bash
helm install loki grafana/loki \
  --set deploymentMode=SingleBinary \
  --set monitoring.lokiCanary.enabled=false \
  --set chunksCache.enabled=false
```

**Skills Demonstrated**:
- Helm chart customization
- Kubernetes resource optimization
- Debugging complex deployments
- Reading Helm documentation

**Outcome**: ✅ Loki running in SingleBinary mode with 2 pods only

---

## Challenge 4: Network Policy Testing
**Problem**: After applying network policies, needed to verify connectivity

**Verification Process**:
```bash
# Test pod-to-pod communication
kubectl run test-pod --rm -it --image=busybox -- wget -O- user-service:3001/health

# Test database access
kubectl run test-db --rm -it --image=mongo:7.0 -- mongosh mongodb://admin:password@mongodb:27017
```

**Skills Demonstrated**:
- Network policy debugging
- Container networking understanding
- Security testing
- Kubernetes troubleshooting tools

---

## Challenge 5: Resource Optimization
**Problem**: 8 nodes required, but want to minimize cost

**Optimization Strategy**:
1. Reduced Prometheus retention from 15d to 7d
2. Disabled Alertmanager in dev
3. Reduced Loki storage from 10Gi to 5Gi
4. Set appropriate resource limits on all pods
5. Implemented node auto-scaling

**Before Optimization**:
- 10 nodes required
- $300/month cost
- High resource waste

**After Optimization**:
- 8 nodes sufficient
- $240/month cost
- 20% cost reduction

**Skills Demonstrated**:
- Cost optimization
- Resource management
- Performance tuning
- Business value awareness

---

## Key Takeaways

### Technical Skills Gained:
✅ Git advanced operations (history recovery)
✅ Terraform state management
✅ Kubernetes capacity planning
✅ Helm chart customization
✅ Network policy implementation
✅ Resource optimization
✅ Troubleshooting methodology

### Soft Skills Demonstrated:
✅ Problem-solving under pressure
✅ Systematic debugging approach
✅ Documentation while working
✅ Learning from failures
✅ Persistence and determination

### DevOps Best Practices:
✅ Infrastructure as Code
✅ Version control everything
✅ Monitor resource usage
✅ Plan for scaling
✅ Document solutions
✅ Test thoroughly