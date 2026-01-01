#!/bin/bash

echo "🚀 Setting up all microservices..."

SERVICES=("user-service" "product-service" "order-service" "payment-service")

for SERVICE in "${SERVICES[@]}"; do
    echo "📦 Setting up $SERVICE..."
    cd services/$SERVICE
    
    # Install dependencies
    npm install
    
    cd ../..
    echo "✅ $SERVICE setup complete!"
done

echo "🎨 Setting up frontend..."
cd frontend
npm install
cd ..

echo "🎉 All services ready!"