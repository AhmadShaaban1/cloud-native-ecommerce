#!/bin/bash

set -e

# Configuration
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
PROJECT_NAME="cloud-native-ecommerce"

# Services to build
SERVICES=("user-service" "product-service" "order-service" "payment-service")

echo "🚀 Building and pushing images to ECR..."
echo "Registry: $ECR_REGISTRY"
echo ""

# Login to ECR
echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin $ECR_REGISTRY

echo "✅ Logged in successfully!"
echo ""

# Build and push each service
for SERVICE in "${SERVICES[@]}"; do
    echo "================================"
    echo "📦 Building $SERVICE..."
    echo "================================"
    
    # Build the image
    docker build -t $PROJECT_NAME/$SERVICE:latest \
        -f ../services/$SERVICE/Dockerfile \
        ../services/$SERVICE/
    
    # Tag for ECR
    docker tag $PROJECT_NAME/$SERVICE:latest \
        $ECR_REGISTRY/$PROJECT_NAME/$SERVICE:latest
    
    # Push to ECR
    echo "⬆️  Pushing $SERVICE to ECR..."
    docker push $ECR_REGISTRY/$PROJECT_NAME/$SERVICE:latest
    
    echo "✅ $SERVICE pushed successfully!"
    echo ""
done

echo "🎉 All images built and pushed to ECR!"
echo ""
echo "Images available at:"
for SERVICE in "${SERVICES[@]}"; do
    echo "  - $ECR_REGISTRY/$PROJECT_NAME/$SERVICE:latest"
done