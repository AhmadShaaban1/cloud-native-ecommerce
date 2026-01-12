# Development vs Production Environment

## Infrastructure Differences

| Component | Development | Production |
|-----------|-------------|------------|
| **VPC CIDR** | 10.0.0.0/16 | 10.1.0.0/16 |
| **Availability Zones** | 2 | 3 |
| **NAT Gateways** | 1 (single) | 3 (multi-AZ HA) |
| **Instance Type** | t3.small | t3.medium |
| **Node Count** | 4-8 (flexible) | 6-12 (auto-scaling) |
| **Disk Size** | 20GB | 30GB |
| **Kubernetes Version** | 1.33 | 1.33 |

## Cost Comparison

### Development (~$200/month)
- EKS Control Plane: $73
- 8x t3.small nodes: $120
- NAT Gateway (1): $32
- EBS Storage: $3
- Data Transfer: ~$5

### Production (~$520/month)
- EKS Control Plane: $73
- 6x t3.medium nodes: $240
- NAT Gateways (3): $96
- EBS Storage: $5
- Data Transfer: ~$15
- Load Balancers: ~$40
- Backups/Snapshots: ~$50

## Application Configuration Differences

| Setting | Development | Production |
|---------|-------------|------------|
| **Replicas** | 2 per service | 3-5 per service |
| **Resource Limits** | Relaxed | Strict |
| **Logging Level** | DEBUG | INFO/WARN |
| **Monitoring Retention** | 7 days | 30 days |
| **Backup Frequency** | Daily | Hourly |
| **SSL/TLS** | Self-signed | Let's Encrypt |
| **Domain** | None | production.domain.com |

## Deployment Strategy

### Development
- Direct deployment via kubectl
- CI/CD triggers on every push to `main`
- No manual approval required
- Downtime acceptable

### Production
- Blue/Green or Canary deployments
- CI/CD triggers on tags (v1.0.0)
- Manual approval required
- Zero-downtime deployments
- Rollback capability