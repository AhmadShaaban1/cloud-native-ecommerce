#!/bin/bash

# Configuration
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
PROJECT_NAME="cloud-native-ecommerce"

# Services to build and push
SERVICES=("user-service" "product-service" "order-service" "payment-service" "frontend")

echo "🚀 Building and pushing images to ECR..."

# Login to ECR
echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin $ECR_REGISTRY

# Build and push each service
for SERVICE in "${SERVICES[@]}"; do
    echo "📦 Building $SERVICE..."
    
    if [ "$SERVICE" = "frontend" ]; then
        CONTEXT="../frontend"
    else
        CONTEXT="../services/$SERVICE"
    fi
    
    # Build image
    docker build -t $PROJECT_NAME/$SERVICE:latest $CONTEXT
    
    # Tag for ECR
    docker tag $PROJECT_NAME/$SERVICE:latest \
        $ECR_REGISTRY/$PROJECT_NAME/$SERVICE:latest
    
    # Push to ECR
    echo "⬆️  Pushing $SERVICE to ECR..."
    docker push $ECR_REGISTRY/$PROJECT_NAME/$SERVICE:latest
    
    echo "✅ $SERVICE pushed successfully!"
done

echo "🎉 All images pushed to ECR!"