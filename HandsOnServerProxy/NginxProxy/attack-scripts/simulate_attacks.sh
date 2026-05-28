#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "======================================"
echo "  SIMULASI KEAMANAN NGINX-PROXY"
echo "======================================"
echo ""

test_security() {
    local name=$1
    local url=$2
    local expected_status=$3
    
    echo -n "Mengetes $name... "
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$status" == "$expected_status" ]; then
        echo -e "${GREEN}BERHASIL (Status: $status)${NC}"
    else
        echo -e "${RED}GAGAL (Status: $status, Expected: $expected_status)${NC}"
    fi
}

echo -e "${BLUE}[SCENARIO 1: AKSES LANGSUNG KE BACKEND (RENTAN)]${NC}"
test_security "Akses API Users" "http://localhost:5000/api.php/users" "200"
test_security "Akses Konfigurasi" "http://localhost:5000/api.php/config" "200"
test_security "Akses File Sensitif" "http://localhost:5000/sensitive.php" "200"
test_security "SQL Injection" "http://localhost:5000/api.php/users?id=' OR 1=1 --" "200"
echo ""

echo -e "${BLUE}[SCENARIO 2: AKSES MELALUI NGINX-PROXY (TERLINDUNGI)]${NC}"
test_security "Akses API Users" "http://localhost:8080/api/users" "200"
test_security "Blokir Konfigurasi" "http://localhost:8080/api/config" "403"
test_security "Blokir File Sensitif" "http://localhost:8080/sensitive.php" "403"
test_security "Blokir SQL Injection" "http://localhost:8080/api/users?id=' OR 1=1 --" "400"
echo ""

echo -e "${BLUE}[SCENARIO 3: INFORMATION LEAKAGE (HIDING HEADERS)]${NC}"
echo "Header dari Backend Langsung (Terlihat PHP & Server):"
curl -s -I http://localhost:5000/api.php/users | grep -E "Server|X-Powered-By"
echo ""
echo "Header dari Nginx-Proxy (Tersembunyi):"
curl -s -I http://localhost:8080/api/users | grep -E "Server|X-Powered-By" || echo "(Header disembunyikan)"
echo ""

echo "======================================"
echo -e "${GREEN}SIMULASI SELESAI${NC}"
echo "======================================"
