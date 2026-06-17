#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKEND_URL="http://localhost:8000"
FRONTEND_URL="http://localhost:8080"

echo "======================================"
echo "  PENETRATION TEST: PROJECT 1 (TANPA PROXY)"
echo "======================================"
echo ""

test_port_exposure() {
    echo -e "${BLUE}[TEST 1] Port Exposure Check${NC}"
    
    echo "Checking backend port 8000..."
    if nc -zv localhost 8000 2>&1 | grep -q "succeeded"; then
        echo -e "${RED}  PORT 8000 TERBUKA - Backend terekspos langsung!${NC}"
    else
        echo -e "${GREEN}  Port 8000 tertutup${NC}"
    fi
    
    echo ""
    echo "Checking frontend port 8080..."
    if nc -zv localhost 8080 2>&1 | grep -q "succeeded"; then
        echo -e "${YELLOW}  Port 8080 terbuka${NC}"
    else
        echo -e "${RED}  Port 8080 tidak dapat diakses${NC}"
    fi
    echo ""
}

test_information_leak() {
    echo -e "${BLUE}[TEST 2] Information Leakage Check${NC}"
    
    echo "Header response dari backend:"
    HEADERS=$(curl -s -I $BACKEND_URL)
    echo "$HEADERS" | grep -E "Server|X-Powered-By|PHP"
    
    if echo "$HEADERS" | grep -q -E "X-Powered-By|PHP"; then
        echo -e "${RED}  RENTAN: Informasi server terekspos!${NC}"
    else
        echo -e "${GREEN}  Aman: Informasi server disembunyikan${NC}"
    fi
    echo ""
}

test_cors_misconfiguration() {
    echo -e "${BLUE}[TEST 3] CORS Misconfiguration Check${NC}"
    
    echo "Memeriksa Access-Control-Allow-Origin..."
    ORIGIN_HEADER=$(curl -s -I $BACKEND_URL/api/products | grep -i "Access-Control-Allow-Origin")
    
    if echo "$ORIGIN_HEADER" | grep -q "*"; then
        echo -e "${RED}  RENTAN: CORS mengizinkan semua origin (*)${NC}"
    else
        echo -e "${GREEN}  Aman: CORS dikonfigurasi dengan benar${NC}"
    fi
    echo ""
}

test_api_endpoints() {
    echo -e "${BLUE}[TEST 4] API Endpoint Enumeration${NC}"
    
    echo "Mencoba mengakses /api/products:"
    curl -s $BACKEND_URL/api/products | head -c 200
    echo -e "\n"
    
    echo "Mencoba mengakses /api/info:"
    curl -s $BACKEND_URL/api/info
    echo -e "\n"
    
    echo "Mencoba endpoint tidak valid:"
    curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" $BACKEND_URL/api/invalid
    echo ""
}

test_rate_limiting() {
    echo -e "${BLUE}[TEST 5] Rate Limiting Check${NC}"
    REQUESTS=50
    echo "Mengirim $REQUESTS request ke API..."
    
    SUCCESS=0
    RATE_LIMITED=0
    
    for i in $(seq 1 $REQUESTS); do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BACKEND_URL/api/products)
        if [ "$STATUS" = "429" ]; then
            ((RATE_LIMITED++))
        elif [ "$STATUS" = "200" ]; then
            ((SUCCESS++))
        fi
    done
    
    echo -e "  Berhasil: $SUCCESS, Dibatasi (429): $RATE_LIMITED"
    
    if [ $RATE_LIMITED -gt 0 ]; then
        echo -e "${GREEN}  Rate limiting berfungsi!${NC}"
    else
        echo -e "${RED}  RENTAN: Tidak ada rate limiting!${NC}"
    fi
    echo ""
}

test_frontend() {
    echo -e "${BLUE}[TEST 6] Frontend Check${NC}"
    
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" $FRONTEND_URL)
    echo "Frontend status: $STATUS"
    
    if [ "$STATUS" = "200" ]; then
        echo -e "${YELLOW}  Frontend dapat diakses${NC}"
    fi
    echo ""
}

main() {
    test_port_exposure
    test_information_leak
    test_cors_misconfiguration
    test_api_endpoints
    test_rate_limiting
    test_frontend
    
    echo "======================================"
    echo -e "${RED}RINGKASAN KERENTANAN PROJECT 1${NC}"
    echo "======================================"
    echo "1. Backend terekspos langsung ke port 8000"
    echo "2. Tidak ada rate limiting"
    echo "3. CORS misconfiguration (mengizinkan *)"
    echo "4. Informasi server terekspos di header"
    echo "======================================"
    echo -e "${GREEN}SOLUSI${NC}"
    echo "- Gunakan reverse proxy seperti Project 2"
    echo "- Tambahkan rate limiting"
    echo "- Hide server headers"
    echo "- Batasi CORS ke domain spesifik"
    echo "======================================"
}

main
