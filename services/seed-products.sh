#!/bin/bash

##############################################################################
# Database Seeding Script
# Adds sample products, users, and test data to your e-commerce platform
##############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Seeding E-Commerce Database                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get base URL
ALB_DNS=$(kubectl get ingress ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
echo "ALB_DNS: $ALB_DNS"

if [ -z "$ALB_DNS" ]; then
    echo -e "${YELLOW}ALB not found, using port-forward...${NC}"
    echo "Run this in another terminal:"
    echo "  kubectl port-forward svc/product-service 3002:3002"
    echo ""
    read -p "Press enter when port-forward is ready..."
    BASE_URL="http://localhost:3002"
else
    BASE_URL="http://$ALB_DNS"
fi

echo "Using base URL: $BASE_URL"
echo ""

# Test connection
echo -e "${YELLOW}Testing connection...${NC}"
if curl -sf "$BASE_URL/api/products" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Product service is reachable${NC}"
else
    echo -e "${YELLOW}⚠ Cannot reach product service${NC}"
    echo "Make sure services are running: kubectl get pods"
    exit 1
fi

# Register admin user
echo ""
echo -e "${YELLOW}Creating admin user...${NC}"

ADMIN_TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@ecommerce.com",
    "password": "Admin123!",
    "name": "Admin User",
    "role": "admin"
  }' | jq -r '.token' 2>/dev/null || echo "")

if [ -z "$ADMIN_TOKEN" ] || [ "$ADMIN_TOKEN" = "null" ]; then
    echo -e "${YELLOW}⚠ Admin user might already exist, trying to login...${NC}"
    
    ADMIN_TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/login" \
      -H "Content-Type: application/json" \
      -d '{
        "email": "admin@ecommerce.com",
        "password": "Admin123!"
      }' | jq -r '.token' 2>/dev/null || echo "")
fi

if [ -z "$ADMIN_TOKEN" ] || [ "$ADMIN_TOKEN" = "null" ]; then
  echo "❌ Admin auth failed — cannot seed products"
  exit 1
fi

if [ -n "$ADMIN_TOKEN" ] && [ "$ADMIN_TOKEN" != "null" ]; then
    echo -e "${GREEN}✓ Admin user ready (token: ${ADMIN_TOKEN:0:20}...)${NC}"
else
    echo -e "${YELLOW}⚠ Could not get admin token, creating products anonymously${NC}"
fi

# Add products
echo ""
echo -e "${YELLOW}Adding sample products...${NC}"

PRODUCTS_ADDED=0

# Electronics
echo "Adding electronics..."

PRODUCTS=(
  '{"name":"MacBook Pro 16\"","description":"Powerful laptop with M3 chip, 16GB RAM, 512GB SSD. Perfect for developers and creators.","price":2499,"category":"Electronics","stock":15,"image":"https://via.placeholder.com/400x300/1976d2/ffffff?text=MacBook+Pro","features":["M3 Chip","16GB RAM","512GB SSD","16-inch Display"]}'
  
  '{"name":"iPhone 15 Pro","description":"Latest iPhone with A17 Pro chip, advanced camera system, titanium design.","price":1199,"category":"Electronics","stock":25,"image":"https://via.placeholder.com/400x300/1976d2/ffffff?text=iPhone+15","features":["A17 Pro Chip","48MP Camera","Titanium Frame","USB-C Port"]}'
  
  '{"name":"AirPods Pro","description":"Active noise cancellation, spatial audio, MagSafe charging case.","price":249,"category":"Electronics","stock":50,"image":"https://via.placeholder.com/400x300/1976d2/ffffff?text=AirPods+Pro","features":["ANC","Spatial Audio","20h Battery","MagSafe"]}'
  
  '{"name":"iPad Air","description":"10.9-inch Liquid Retina display, M1 chip, works with Apple Pencil.","price":599,"category":"Electronics","stock":30,"image":"https://via.placeholder.com/400x300/1976d2/ffffff?text=iPad+Air","features":["M1 Chip","10.9-inch Display","Apple Pencil Support","5G Ready"]}'
  
  '{"name":"Sony WH-1000XM5","description":"Industry-leading noise canceling headphones with exceptional sound quality.","price":399,"category":"Electronics","stock":20,"image":"https://via.placeholder.com/400x300/1976d2/ffffff?text=Sony+WH-1000XM5","features":["Best ANC","30h Battery","Multi-point Connection","Premium Sound"]}'
)
curl -s "$BASE_URL/api/products?name=MacBook" | grep -q "MacBook" && continue
for product in "${PRODUCTS[@]}"; do
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/products" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -d "$product")
    
    if echo "$RESPONSE" | grep -q "product\|_id\|name"; then
        ((PRODUCTS_ADDED++))
        echo -e "  ${GREEN}✓${NC} Added: $(echo $product | jq -r '.name')"
    else
        echo -e "  ${YELLOW}⚠${NC} Failed: $(echo $product | jq -r '.name')"
    fi
done

# Clothing
echo "Adding clothing..."

CLOTHING=(
  '{"name":"Nike Air Max","description":"Classic running shoes with Air cushioning technology.","price":129,"category":"Clothing","stock":40,"image":"https://via.placeholder.com/400x300/dc004e/ffffff?text=Nike+Air+Max","features":["Air Cushioning","Breathable Mesh","Durable Rubber Sole"]}'
  
  '{"name":"Levi'\''s 501 Jeans","description":"Original fit jeans, timeless style, premium denim.","price":89,"category":"Clothing","stock":60,"image":"https://via.placeholder.com/400x300/dc004e/ffffff?text=Levis+501","features":["100% Cotton","Classic Fit","Multiple Washes Available"]}'
  
  '{"name":"Patagonia Fleece","description":"Warm fleece jacket, eco-friendly materials, perfect for outdoors.","price":149,"category":"Clothing","stock":35,"image":"https://via.placeholder.com/400x300/dc004e/ffffff?text=Patagonia+Fleece","features":["Recycled Materials","Warm & Lightweight","Fair Trade Certified"]}'
)

for product in "${CLOTHING[@]}"; do
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/products" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -d "$product")
    
    if echo "$RESPONSE" | grep -q "product\|_id\|name"; then
        ((PRODUCTS_ADDED++))
        echo -e "  ${GREEN}✓${NC} Added: $(echo $product | jq -r '.name')"
    else
        echo -e "  ${YELLOW}⚠${NC} Failed: $(echo $product | jq -r '.name')"
    fi
done

# Books
echo "Adding books..."

BOOKS=(
  '{"name":"Clean Code","description":"A Handbook of Agile Software Craftsmanship by Robert Martin.","price":45,"category":"Books","stock":50,"image":"https://via.placeholder.com/400x300/4caf50/ffffff?text=Clean+Code","features":["Programming Best Practices","Industry Standard","Must-Read for Developers"]}'
  
  '{"name":"Designing Data-Intensive Applications","description":"The essential guide to building scalable, reliable systems.","price":55,"category":"Books","stock":40,"image":"https://via.placeholder.com/400x300/4caf50/ffffff?text=DDIA","features":["System Design","Distributed Systems","Database Internals"]}'
  
  '{"name":"Atomic Habits","description":"Tiny changes, remarkable results. Build good habits, break bad ones.","price":27,"category":"Books","stock":70,"image":"https://via.placeholder.com/400x300/4caf50/ffffff?text=Atomic+Habits","features":["Self-Improvement","Habit Formation","Bestseller"]}'
)

for product in "${BOOKS[@]}"; do
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/products" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -d "$product")
    
    if echo "$RESPONSE" | grep -q "product\|_id\|name"; then
        ((PRODUCTS_ADDED++))
        echo -e "  ${GREEN}✓${NC} Added: $(echo $product | jq -r '.name')"
    else
        echo -e "  ${YELLOW}⚠${NC} Failed: $(echo $product | jq -r '.name')"
    fi
done

# Create test user
echo ""
echo -e "${YELLOW}Creating test user...${NC}"

TEST_USER_TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@example.com",
    "password": "Demo123!",
    "name": "Demo User"
  }' | jq -r '.token' 2>/dev/null || echo "")

if [ -n "$TEST_USER_TOKEN" ] && [ "$TEST_USER_TOKEN" != "null" ]; then
    echo -e "${GREEN}✓ Test user created${NC}"
    echo "  Email: demo@example.com"
    echo "  Password: Demo123!"
else
    echo -e "${YELLOW}⚠ Test user might already exist${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Database Seeding Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Products added: $PRODUCTS_ADDED"
echo ""
echo "Test Accounts:"
echo "  Admin:"
echo "    Email: admin@ecommerce.com"
echo "    Password: Admin123!"
echo ""
echo "  Demo User:"
echo "    Email: demo@example.com"
echo "    Password: Demo123!"
echo ""
echo "Access your store:"
echo "  URL: http://$ALB_DNS"
echo ""
echo "Next steps:"
echo "  1. Visit the store in your browser"
echo "  2. Browse products"
echo "  3. Add items to cart"
echo "  4. Complete checkout"
echo ""