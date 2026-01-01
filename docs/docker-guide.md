# 🐳 Docker Guide

## Image Sizes
- User Service: ~150MB (Alpine-based)
- Product Service: ~150MB
- Order Service: ~150MB
- Payment Service: ~150MB
- Frontend: ~25MB (Nginx)

## Build Commands

<!-- ### Build Single Service
```bash
docker build -t user-service:latest ./services/user-service
``` -->

### Build All Services
```bash
docker-compose build
```

### Run Locally
```bash
docker-compose up -d
```

## ECR Push
```bash
./scripts/push-to-ecr.sh
```

## Best Practices Used
✅ Multi-stage builds
✅ Non-root user
✅ Health checks
✅ .dockerignore
✅ Layer caching optimization
✅ Security scanning ready