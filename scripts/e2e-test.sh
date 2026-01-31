#!/bin/bash

set -e

echo "🧪 Starting E2E Integration Tests..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
FRONTEND_URL="http://localhost:3000"
USER_API="http://localhost:3001"
PRODUCT_API="http://localhost:3002"
ORDER_API="http://localhost:3003"
PAYMENT_API="http://localhost:3004"

# Test counter
PASSED=0
FAILED=0

# Helper function
test_endpoint() {
    local name=$1
    local url=$2
    local expected_status=$3
    
    echo -n "Testing $name... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" $url)
    
    if [ "$response" -eq "$expected_status" ]; then
        echo -e "${GREEN}✓ PASSED${NC} (Status: $response)"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC} (Expected: $expected_status, Got: $response)"
        ((FAILED++))
    fi
}

echo ""
echo "=== Health Checks ==="
test_endpoint "User Service Health" "$USER_API/health" 200
test_endpoint "Product Service Health" "$PRODUCT_API/health" 200
test_endpoint "Order Service Health" "$ORDER_API/health" 200
test_endpoint "Payment Service Health" "$PAYMENT_API/health" 200

echo ""
echo "=== User Flow ==="

# Register user
echo -n "Registering new user... "
REGISTER_RESPONSE=$(curl -s -X POST $USER_API/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "name": "Test User"
  }')

if echo "$REGISTER_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✓ PASSED${NC}"
    ((PASSED++))
    TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.token')
else
    echo -e "${RED}✗ FAILED${NC}"
    ((FAILED++))
    TOKEN=""
fi

# Get products
echo -n "Fetching products... "
PRODUCTS=$(curl -s $PRODUCT_API/api/products)
if echo "$PRODUCTS" | grep -q "products"; then
    echo -e "${GREEN}✓ PASSED${NC}"
    ((PASSED++))
    PRODUCT_ID=$(echo $PRODUCTS | jq -r '.products[0]._id')
else
    echo -e "${RED}✗ FAILED${NC}"
    ((FAILED++))
fi

# Create order
if [ -n "$TOKEN" ] && [ -n "$PRODUCT_ID" ]; then
    echo -n "Creating order... "
    ORDER_RESPONSE=$(curl -s -X POST $ORDER_API/api/orders \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"items\": [{
          \"productId\": \"$PRODUCT_ID\",
          \"quantity\": 2
        }]
      }")
    
    if echo "$ORDER_RESPONSE" | grep -q "order"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED++))
        ORDER_ID=$(echo $ORDER_RESPONSE | jq -r '.order._id')
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED++))
    fi
fi

echo ""
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed!${NC}"
    exit 1
fi