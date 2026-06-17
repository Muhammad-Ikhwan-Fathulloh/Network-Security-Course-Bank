#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROXY_URL="http://localhost"

echo "======================================"
echo "  PENETRATION TEST: PROJECT 2 (DENGAN PROXY)"
echo "======================================"
echo ""

test_single_entry_point() {
    echo -e "${BLUE}[TEST 1] Single Entry Point Check${NC}"
    
    echo "Memeriksa port 80 (proxy)..."
    if nc -zv localhost 80 2>&1 | grep -q "succeeded"; then
        echo -e "${GREEN}  Port 80 terbuka (hanya proxy yang terlihat)${NC}"
    else
        echo -e "${RED}  Proxy tidak dapat diakses${NC}"
    fi
    
    echo ""
    echo "Memeriksa apakah port backend (tidak seharusnya terbuka)..."
    if nc -zv localhost 8000 2>&1 | grep -q "succeeded"; then
        echo -e "${RED}  PORT BACKEND TERBUKA - Konfigurasi salah!${NC}"
    else
        echo -e "${GREEN}  Port backend tertutup (aman)${NC}"
    fi
    echo ""
}

test_proxy_headers() {
    echo -e "${BLUE}[TEST 2] Proxy Header Check${NC}"
    
    echo "Header response dari proxy:"
    HEADERS=$(curl -s -I $PROXY_URL)
    echo "$HEADERS" | grep -E "Server|X-Powered-By|PHP"
    
    if echo "$HEADERS" | grep -q -E "nginx"; then
        echo -e "${GREEN}  Header menunjukkan Nginx (bukan backend langsung)${NC}"
    else
        echo -e "${YELLOW}  Periksa konfigurasi header proxy${NC}"
    fi
    echo ""
}

test_api_via_proxy() {
    echo -e "${BLUE}[TEST 3] API Access via Proxy${NC}"
    
    echo "Akses /api/products via proxy:"
    curl -s $PROXY_URL/api/products | head -c 200
    echo -e "\n"
    
    echo "Akses /api/info via proxy:"
    curl -s $PROXY_URL/api/info
    echo -e "\n"
}

test_frontend_via_proxy() {
    echo -e "${BLUE}[TEST 4] Frontend Access via Proxy${NC}"
    
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" $PROXY_URL)
    echo "Frontend status via proxy: $STATUS"
    echo ""
}

test_path_routing() {
    echo -e "${BLUE}[TEST 5] Proxy Path Routing${NC}"
    
    echo "Testing root path (/) → frontend:"
    curl -s -o /dev/null -w "Status: %{http_code}\n" $PROXY_URL/
    
    echo "Testing /api path → backend:"
    curl -s -o /dev/null -w "Status: %{http_code}\n" $PROXY_URL/api/products
    echo ""
}

main() {
    test_single_entry_point
    test_proxy_headers
    test_api_via_proxy
    test_frontend_via_proxy
    test_path_routing
    
    echo "======================================"
    echo -e "${GREEN}KEAMANAN PROJECT 2${NC}"
    echo "======================================"
    echo "1. Backend tidak terekspos langsung"
    echo "2. Single entry point via port 80"
    echo "3. Header server dari proxy (bukan backend)"
    echo "======================================"
    echo -e "${YELLOW}REKOMENDASI TAMBAHAN${NC}"
    echo "- Tambahkan rate limiting di Nginx"
    echo "- Tambahkan security headers"
    echo "- Gunakan HTTPS/SSL"
    echo "- Tambahkan WAF (Web Application Firewall)"
    echo "======================================"
}

main
