# E-Commerce Frontend

React-based frontend for the cloud-native e-commerce platform.

## Quick Start

```bash
npm install
npm start
```

## Available Scripts

- `npm start` - Start development server
- `npm build` - Build for production
- `npm test` - Run tests

## Environment Variables

Copy `.env.example` to `.env` and update the values.

## Docker

```bash
docker build -t ecommerce-frontend .
docker run -p 3000:80 ecommerce-frontend
```

## Next Steps

1. Copy all source files from artifacts
2. Update environment variables
3. Test locally with `npm start`
4. Build Docker image
5. Deploy to Kubernetes

kubectl port-forward service/frontend 8080:80


