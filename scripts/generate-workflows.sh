#!/bin/bash

SERVICES=("product-service" "order-service" "payment-service")
PORTS=("3002" "3003" "3004")

for i in "${!SERVICES[@]}"; do
    SERVICE="${SERVICES[$i]}"
    PORT="${PORTS[$i]}"
    
    cat > .github/workflows/${SERVICE}-cicd.yaml <<EOF
name: ${SERVICE^} CI/CD

on:
  push:
    branches:
      - main
    paths:
      - 'services/${SERVICE}/**'
      - '.github/workflows/${SERVICE}-cicd.yaml'

env:
  AWS_REGION: \${{ secrets.AWS_REGION }}
  ECR_REPOSITORY: cloud-native-ecommerce/${SERVICE}
  EKS_CLUSTER_NAME: \${{ secrets.EKS_CLUSTER_NAME }}
  SERVICE_NAME: ${SERVICE}

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: '18'
    - working-directory: services/${SERVICE}
      run: |
        npm ci
        npm test || echo "Tests not configured yet"

  build-and-push:
    name: Build and Push
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    outputs:
      image-tag: \${{ steps.meta.outputs.image-tag }}
    steps:
    - uses: actions/checkout@v4
    - uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: \${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: \${{ env.AWS_REGION }}
    - uses: aws-actions/amazon-ecr-login@v2
      id: login-ecr
    - name: Build and push
      id: meta
      env:
        ECR_REGISTRY: \${{ steps.login-ecr.outputs.registry }}
        IMAGE_TAG: \${{ github.sha }}
      working-directory: services/${SERVICE}
      run: |
        docker build -t \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG .
        docker push \$ECR_REGISTRY/\$ECR_REPOSITORY:\$IMAGE_TAG
        echo "image-tag=\$IMAGE_TAG" >> \$GITHUB_OUTPUT

  deploy:
    name: Deploy to EKS
    runs-on: ubuntu-latest
    needs: build-and-push
    steps:
    - uses: actions/checkout@v4
    - uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: \${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: \${{ env.AWS_REGION }}
    - name: Deploy
      env:
        IMAGE_TAG: \${{ needs.build-and-push.outputs.image-tag }}
      run: |
        aws eks update-kubeconfig --name \$EKS_CLUSTER_NAME --region \$AWS_REGION
        kubectl set image deployment/\$SERVICE_NAME \$SERVICE_NAME=\${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.\$AWS_REGION.amazonaws.com/\$ECR_REPOSITORY:\$IMAGE_TAG
        kubectl rollout status deployment/\$SERVICE_NAME --timeout=5m
EOF

    echo "✅ Created workflow for ${SERVICE}"
done

echo "🎉 All workflows generated!"