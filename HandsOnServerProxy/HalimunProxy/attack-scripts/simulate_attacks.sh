#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "======================================"
echo "  SIMULASI KEAMANAN HALIMUN-PROXY"
echo "======================================"
echo ""

test_security() {
    local name=$1
    local url=$2
    local expected_status=$3
    local auth=$4
    local method=${5:-GET}
    
    echo -n "Mengetes $name... "
    if [ -n "$auth" ]; then
        status=$(curl -s -o /dev/null -u "$auth" -X "$method" -w "%{http_code}" "$url")
    else
        status=$(curl -s -o /dev/null -X "$method" -w "%{http_code}" "$url")
    fi
    
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

echo -e "${BLUE}[SCENARIO 2: AKSES MELALUI HALIMUN-PROXY (TERLINDUNGI)]${NC}"
echo "Catatan: Halimun-Proxy menolak request non-enkripsi atau format salah."
test_security "Akses API (Tanpa Enkripsi)" "http://localhost:8080/proxy/1/users" "401" "admin:admin" "POST"
test_security "Akses Tanpa Auth" "http://localhost:8080/proxy/1/users" "401" "" "POST"
test_security "Blokir Konfigurasi" "http://localhost:8080/proxy/1/config" "401" "admin:admin" "POST"
echo ""

echo -e "${BLUE}[SCENARIO 3: INFORMATION LEAKAGE (HIDING HEADERS)]${NC}"
echo "Header dari Backend Langsung (Terlihat PHP & Server):"
curl -s -I http://localhost:5000/api.php/users | grep -E "Server|X-Powered-By"
echo ""
echo "Header dari Nginx-Gateway (Tersembunyi):"
curl -s -I http://localhost:8080/ | grep -E "Server|X-Powered-By" || echo "(Header disembunyikan)"
echo ""

echo "======================================"
echo -e "${GREEN}SIMULASI SELESAI${NC}"
echo "======================================"
echo "Gunakan Dashboard di http://localhost:8080 untuk tes enkripsi penuh."
