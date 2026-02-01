# User Service

Handles user authentication and health checks.

## Endpoints
- GET /health
- POST /api/auth/register
- POST /api/auth/login

kubectl port-forward service/user-service 8081:80
