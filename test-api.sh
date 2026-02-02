#!/bin/bash

# Test script for Voith Backend API
# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:5000"
TOKEN=""

echo -e "${YELLOW}=== Voith Backend API Test Suite ===${NC}\n"

# Test 1: Health Check
echo -e "${YELLOW}Test 1: Health Check${NC}"
RESPONSE=$(curl -s ${BASE_URL}/health)
if echo "$RESPONSE" | grep -q "Server is running"; then
    echo -e "${GREEN}✓ Health check passed${NC}"
    echo "$RESPONSE" | jq .
else
    echo -e "${RED}✗ Health check failed${NC}"
fi
echo ""

# Test 2: Admin Login
echo -e "${YELLOW}Test 2: Admin Login${NC}"
LOGIN_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/admin/login \
    -H "Content-Type: application/json" \
    -d '{"email":"admin@voith.com","password":"Admin@123"}')

if echo "$LOGIN_RESPONSE" | grep -q "Login successful"; then
    echo -e "${GREEN}✓ Admin login successful${NC}"
    TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.token')
    echo "Token: ${TOKEN:0:50}..."
else
    echo -e "${RED}✗ Admin login failed${NC}"
    echo "$LOGIN_RESPONSE" | jq .
fi
echo ""

# Test 3: Get Admin Profile
echo -e "${YELLOW}Test 3: Get Admin Profile${NC}"
PROFILE_RESPONSE=$(curl -s ${BASE_URL}/api/admin/profile \
    -H "Authorization: Bearer $TOKEN")

if echo "$PROFILE_RESPONSE" | grep -q "admin@voith.com"; then
    echo -e "${GREEN}✓ Admin profile retrieved${NC}"
    echo "$PROFILE_RESPONSE" | jq .
else
    echo -e "${RED}✗ Failed to get admin profile${NC}"
fi
echo ""

# Test 4: Unauthorized Access
echo -e "${YELLOW}Test 4: Unauthorized Access (without token)${NC}"
UNAUTH_RESPONSE=$(curl -s ${BASE_URL}/api/admin/images/all)

if echo "$UNAUTH_RESPONSE" | grep -q "Authentication token required"; then
    echo -e "${GREEN}✓ Properly rejected unauthorized access${NC}"
    echo "$UNAUTH_RESPONSE" | jq .
else
    echo -e "${RED}✗ Security issue: Unauthorized access allowed${NC}"
fi
echo ""

# Test 5: Wrong Password
echo -e "${YELLOW}Test 5: Wrong Password${NC}"
WRONG_PASS=$(curl -s -X POST ${BASE_URL}/api/admin/login \
    -H "Content-Type: application/json" \
    -d '{"email":"admin@voith.com","password":"WrongPassword"}')

if echo "$WRONG_PASS" | grep -q "Invalid credentials"; then
    echo -e "${GREEN}✓ Properly rejected wrong password${NC}"
    echo "$WRONG_PASS" | jq .
else
    echo -e "${RED}✗ Security issue: Wrong password accepted${NC}"
fi
echo ""

# Test 6: Get All Images (Public)
echo -e "${YELLOW}Test 6: Get All Images (Public - No Auth Required)${NC}"
PUBLIC_IMAGES=$(curl -s ${BASE_URL}/api/public/images)

if echo "$PUBLIC_IMAGES" | grep -q "success"; then
    echo -e "${GREEN}✓ Public images endpoint works${NC}"
    echo "$PUBLIC_IMAGES" | jq .
else
    echo -e "${RED}✗ Public images endpoint failed${NC}"
fi
echo ""

# Test 7: Get All Images (Admin)
echo -e "${YELLOW}Test 7: Get All Images (Admin - With Auth)${NC}"
ADMIN_IMAGES=$(curl -s ${BASE_URL}/api/admin/images/all \
    -H "Authorization: Bearer $TOKEN")

if echo "$ADMIN_IMAGES" | grep -q "success"; then
    echo -e "${GREEN}✓ Admin images endpoint works${NC}"
    echo "$ADMIN_IMAGES" | jq .
else
    echo -e "${RED}✗ Admin images endpoint failed${NC}"
fi
echo ""

# Test 8: Upload Image
if [ -f "test-image.png" ]; then
    echo -e "${YELLOW}Test 8: Upload Image${NC}"
    UPLOAD_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/admin/images/upload \
        -H "Authorization: Bearer $TOKEN" \
        -F "image=@test-image.png")
    
    if echo "$UPLOAD_RESPONSE" | grep -q "Image uploaded successfully"; then
        echo -e "${GREEN}✓ Image upload successful${NC}"
        echo "$UPLOAD_RESPONSE" | jq .
        IMAGE_ID=$(echo "$UPLOAD_RESPONSE" | jq -r '.data.id')
        FILENAME=$(echo "$UPLOAD_RESPONSE" | jq -r '.data.filename')
    else
        echo -e "${RED}✗ Image upload failed${NC}"
    fi
    echo ""
    
    # Test 9: Get Single Image by ID
    if [ ! -z "$IMAGE_ID" ]; then
        echo -e "${YELLOW}Test 9: Get Single Image by ID${NC}"
        SINGLE_IMAGE=$(curl -s ${BASE_URL}/api/public/images/${IMAGE_ID})
        
        if echo "$SINGLE_IMAGE" | grep -q "success"; then
            echo -e "${GREEN}✓ Get single image works${NC}"
            echo "$SINGLE_IMAGE" | jq .
        else
            echo -e "${RED}✗ Get single image failed${NC}"
        fi
        echo ""
        
        # Test 10: Get Image File
        echo -e "${YELLOW}Test 10: Get Image File${NC}"
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" ${BASE_URL}/api/public/images/file/${FILENAME})
        
        if [ "$HTTP_CODE" = "200" ]; then
            echo -e "${GREEN}✓ Image file retrieval works (HTTP $HTTP_CODE)${NC}"
        else
            echo -e "${RED}✗ Image file retrieval failed (HTTP $HTTP_CODE)${NC}"
        fi
        echo ""
    fi
else
    echo -e "${YELLOW}Test 8-10: Skipped (test-image.png not found)${NC}"
    echo ""
fi

echo -e "${YELLOW}=== Test Suite Complete ===${NC}"
