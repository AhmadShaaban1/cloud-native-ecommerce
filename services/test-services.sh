#!/bin/bash

##############################################################################
# Complete Service Testing Script
# Tests user, product, order, and payment services end-to-end
##############################################################################

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  E-Commerce Platform - Complete Service Testing           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get base URL
ALB_DNS=$(kubectl get ingress ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
echo "ALB_DNS: $ALB_DNS"

if [ -z "$ALB_DNS" ]; then
    echo -e "${YELLOW}No ingress found, using localhost (make sure port-forward is running)${NC}"
    BASE_URL="http://localhost"
else
    BASE_URL="http://$ALB_DNS"
fi

echo "Testing URL: $BASE_URL"
echo ""

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test function
test_endpoint() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected=$5
    local token=$6
    
    ((TOTAL_TESTS++)) || true || true
    
    echo -n "Testing $name... "
    
    local cmd="curl -s -X $method \"$BASE_URL$endpoint\""
    
    if [ -n "$data" ]; then
        cmd="$cmd -H \"Content-Type: application/json\" -d '$data'"
    fi
    
    if [ -n "$token" ]; then
        cmd="$cmd -H \"Authorization: Bearer $token\""
    fi
    
    local response=$(eval $cmd 2>/dev/null || echo '{"error":"request failed"}')
    
    if echo "$response" | grep -q "$expected"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED_TESTS++)) || true
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "  Response: ${response:0:100}"
        ((FAILED_TESTS++)) || true
        return 1
    fi
}

# Section header
print_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# 1. Health Checks
print_section "1. Health Checks"

test_endpoint "User Service Health" "GET" "/api/auth/health" "" "healthy\|ok\|status"
test_endpoint "Product Service Health" "GET" "/api/products/health" "" "healthy\|ok\|status"
test_endpoint "Order Service Health" "GET" "/api/orders/health" "" "healthy\|ok\|status"
test_endpoint "Payment Service Health" "GET" "/api/payments/health" "" "healthy\|ok\|status"

# 2. User Service Tests
print_section "2. User Service - Registration & Authentication"

# Generate unique email
TIMESTAMP=$(date +%s)
TEST_EMAIL="test-${TIMESTAMP}@example.com"

echo "Registering new user: $TEST_EMAIL"

REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"Test123!\",
    \"name\": \"Test User $TIMESTAMP\"
  }")

TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.token' 2>/dev/null || echo "")

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    echo -e "${GREEN}✓ User registered successfully${NC}"
    echo "  Token: ${TOKEN:0:30}..."
    ((PASSED_TESTS++)) || true
else
    echo -e "${RED}✗ User registration failed${NC}"
    echo "  Response: $REGISTER_RESPONSE"
    ((FAILED_TESTS++)) || true
fi
((TOTAL_TESTS++)) || true || true

# Test login
if [ -n "$TOKEN" ]; then
    echo ""
    echo "Testing login with same credentials..."
    
    LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
      -H "Content-Type: application/json" \
      -d "{
        \"email\": \"$TEST_EMAIL\",
        \"password\": \"Test123!\"
      }")
    
    LOGIN_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token' 2>/dev/null || echo "")
    
    if [ -n "$LOGIN_TOKEN" ] && [ "$LOGIN_TOKEN" != "null" ]; then
        echo -e "${GREEN}✓ Login successful${NC}"
        ((PASSED_TESTS++)) || true
    else
        echo -e "${RED}✗ Login failed${NC}"
        ((FAILED_TESTS++)) || true
    fi
    ((TOTAL_TESTS++)) || true
fi

# 3. Product Service Tests
print_section "3. Product Service - Catalog Operations"

# Get all products
echo "Fetching all products..."
PRODUCTS_RESPONSE=$(curl -s "$BASE_URL/api/products")
PRODUCT_COUNT=$(echo "$PRODUCTS_RESPONSE" | jq '.products | length' 2>/dev/null || echo "0")

if [ "$PRODUCT_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $PRODUCT_COUNT products${NC}"
    ((PASSED_TESTS++)) || true
    
    # Get first product ID
    PRODUCT_ID=$(echo "$PRODUCTS_RESPONSE" | jq -r '.products[0]._id' 2>/dev/null || echo "")
    PRODUCT_NAME=$(echo "$PRODUCTS_RESPONSE" | jq -r '.products[0].name' 2>/dev/null || echo "Unknown")
    echo "  First product: $PRODUCT_NAME"
else
    echo -e "${YELLOW}⚠ No products found (run seed-database.sh first)${NC}"
    ((FAILED_TESTS++)) || true
fi
((TOTAL_TESTS++)) || true

# Get single product
if [ -n "$PRODUCT_ID" ]; then
    echo ""
    echo "Fetching product details for: $PRODUCT_ID"
    
    PRODUCT_DETAIL=$(curl -s "$BASE_URL/api/products/$PRODUCT_ID")
    
    if echo "$PRODUCT_DETAIL" | grep -q "product\|name\|price"; then
        echo -e "${GREEN}✓ Product details retrieved${NC}"
        ((PASSED_TESTS++)) || true
    else
        echo -e "${RED}✗ Failed to get product details${NC}"
        ((FAILED_TESTS++)) || true
    fi
    ((TOTAL_TESTS++)) || true
fi

# Search products
echo ""
test_endpoint "Product Search" "GET" "/api/products?search=test" "" "products"

# 4. Order Service Tests
print_section "4. Order Service - Cart & Orders"

if [ -n "$TOKEN" ] && [ -n "$PRODUCT_ID" ]; then
    echo "Creating order with product: $PRODUCT_ID"
    
    ORDER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/orders" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"items\": [
          {
            \"productId\": \"$PRODUCT_ID\",
            \"quantity\": 2,
            \"price\": 99.99
          }
        ],
        \"shippingAddress\": {
          \"fullName\": \"Test User\",
          \"address\": \"123 Test St\",
          \"city\": \"Test City\",
          \"state\": \"TC\",
          \"zipCode\": \"12345\",
          \"country\": \"USA\",
          \"phone\": \"555-0123\"
        },
        \"totalAmount\": 199.98
      }")
    
    ORDER_ID=$(echo "$ORDER_RESPONSE" | jq -r '.order._id' 2>/dev/null || echo "")
    
    if [ -n "$ORDER_ID" ] && [ "$ORDER_ID" != "null" ]; then
        echo -e "${GREEN}✓ Order created successfully${NC}"
        echo "  Order ID: $ORDER_ID"
        ((PASSED_TESTS++)) || true
    else
        echo -e "${RED}✗ Order creation failed${NC}"
        echo "  Response: ${ORDER_RESPONSE:0:200}"
        ((FAILED_TESTS++)) || true
    fi
    ((TOTAL_TESTS++)) || true
    
    # Get order details
    if [ -n "$ORDER_ID" ]; then
        echo ""
        echo "Fetching order details..."
        
        ORDER_DETAIL=$(curl -s "$BASE_URL/api/orders/$ORDER_ID" \
          -H "Authorization: Bearer $TOKEN")
        
        if echo "$ORDER_DETAIL" | grep -q "order\|_id"; then
            echo -e "${GREEN}✓ Order details retrieved${NC}"
            ((PASSED_TESTS++)) || true
        else
            echo -e "${RED}✗ Failed to get order details${NC}"
            ((FAILED_TESTS++)) || true
        fi
        ((TOTAL_TESTS++)) || true
    fi
    
    # Get my orders
    echo ""
    echo "Fetching user's orders..."
    
    MY_ORDERS=$(curl -s "$BASE_URL/api/orders/my-orders" \
      -H "Authorization: Bearer $TOKEN")
    
    if echo "$MY_ORDERS" | grep -q "orders"; then
        ORDER_COUNT=$(echo "$MY_ORDERS" | jq '.orders | length' 2>/dev/null || echo "0")
        echo -e "${GREEN}✓ Found $ORDER_COUNT order(s)${NC}"
        ((PASSED_TESTS++)) || true
    else
        echo -e "${RED}✗ Failed to get user orders${NC}"
        ((FAILED_TESTS++)) || true
    fi
    ((TOTAL_TESTS++)) || true
else
    echo -e "${YELLOW}⚠ Skipping order tests (no auth token or product)${NC}"
fi

# 5. Payment Service Tests
print_section "5. Payment Service - Payment Processing"

if [ -n "$TOKEN" ] && [ -n "$ORDER_ID" ]; then
    echo "Processing payment for order: $ORDER_ID"
    
    PAYMENT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/payments/process" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d "{
        \"orderId\": \"$ORDER_ID\",
        \"amount\": 199.98,
        \"paymentMethod\": \"card\",
        \"cardDetails\": {
          \"cardNumber\": \"4111111111111111\",
          \"cardName\": \"Test User\",
          \"expiryDate\": \"12/25\",
          \"cvv\": \"123\"
        }
      }")
    
    if echo "$PAYMENT_RESPONSE" | grep -q "payment\|transaction\|success"; then
        echo -e "${GREEN}✓ Payment processed successfully${NC}"
        ((PASSED_TESTS++)) || true
    else
        echo -e "${YELLOW}⚠ Payment processing (mock might not be fully implemented)${NC}"
        echo "  Response: ${PAYMENT_RESPONSE:0:200}"
        ((FAILED_TESTS++)) || true
    fi
    ((TOTAL_TESTS++)) || true
else
    echo -e "${YELLOW}⚠ Skipping payment tests (no order to pay for)${NC}"
fi

# 6. Frontend Tests
print_section "6. Frontend Accessibility"

test_endpoint "Frontend Homepage" "GET" "/" "" "html\|<!DOCTYPE\|<html"
test_endpoint "Frontend Health" "GET" "/health" "" "healthy\|ok"

# Summary
print_section "Test Summary"

echo "Total Tests: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
echo ""

PASS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
echo "Pass Rate: $PASS_RATE%"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ All tests passed! Your platform is working perfectly!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠ Some tests failed. Check the output above for details.${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
fi