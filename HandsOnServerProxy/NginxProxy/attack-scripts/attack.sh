#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "======================================"
echo "  SIMULASI SERANGAN KEAMANAN"
echo "======================================"
echo ""

test_port_scanning() {
    echo -e "${BLUE}[TEST 1] Port Scanning${NC}"
    echo "Memindai port 5000 (backend langsung):"
    if nc -zv localhost 5000 2>&1 | grep -q "succeeded"; then
        echo -e "${RED}  PORT 5000 TERBUKA - Backend terekspos!${NC}"
    else
        echo -e "${GREEN}  Port 5000 tertutup${NC}"
    fi
    
    echo ""
    echo "Memindai port 8080 (proxy):"
    if nc -zv localhost 8080 2>&1 | grep -q "succeeded"; then
        echo -e "${YELLOW}  Port 8080 terbuka (hanya proxy yang terlihat)${NC}"
    else
        echo -e "${RED}  Port 8080 tidak dapat diakses${NC}"
    fi
    
    echo ""
    echo "Memindai port backend protected (seharusnya tidak terlihat):"
    if nc -zv localhost 80 2>&1 | grep -q "succeeded"; then
        echo -e "${RED}  Backend protected terekspos!${NC}"
    else
        echo -e "${GREEN}  Backend protected TIDAK TERDETEKSI${NC}"
    fi
    echo ""
}

test_sensitive_access() {
    echo -e "${BLUE}[TEST 2] Akses File Sensitif${NC}"
    
    echo "Mengakses /sensitive.php pada backend langsung:"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/sensitive.php)
    if [ "$STATUS" = "200" ]; then
        echo -e "${RED}  BERHASIL (HTTP $STATUS) - File sensitif terekspos!${NC}"
    else
        echo -e "${GREEN}  GAGAL (HTTP $STATUS)${NC}"
    fi
    
    echo ""
    echo "Mengakses /sensitive.php melalui proxy:"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/sensitive.php)
    if [ "$STATUS" = "403" ] || [ "$STATUS" = "404" ]; then
        echo -e "${GREEN}  DIBLOKIR (HTTP $STATUS) - Proxy bekerja dengan baik!${NC}"
    else
        echo -e "${RED}  BERHASIL (HTTP $STATUS) - Proxy gagal memblokir!${NC}"
    fi
    echo ""
}

test_config_exposure() {
    echo -e "${BLUE}[TEST 3] Eksposur Data Konfigurasi${NC}"
    
    echo "Mengakses konfigurasi pada backend langsung:"
    RESPONSE=$(curl -s http://localhost:5000/api.php/config)
    if echo "$RESPONSE" | grep -q "password"; then
        echo -e "${RED}  DATA KONFIGURASI TEREKSPOS!${NC}"
        echo "$RESPONSE" | head -c 200
    else
        echo -e "${GREEN}  Konfigurasi tidak terekspos${NC}"
    fi
    
    echo ""
    echo "Mengakses konfigurasi melalui proxy:"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/config)
    if [ "$STATUS" = "403" ]; then
        echo -e "${GREEN}  DIBLOKIR (HTTP $STATUS) - Konfigurasi aman${NC}"
    else
        echo -e "${RED}  KONFIGURASI TERAKSES (HTTP $STATUS)${NC}"
    fi
    echo ""
}

test_sql_injection() {
    echo -e "${BLUE}[TEST 4] SQL Injection${NC}"
    PAYLOAD="' OR '1'='1"
    
    echo "Mencoba SQL Injection pada backend langsung:"
    RESPONSE=$(curl -s "http://localhost:5000/api.php/users?id=${PAYLOAD}")
    if echo "$RESPONSE" | grep -qi "error\|warning"; then
        echo -e "${GREEN}  Aman - Tidak ada informasi database bocor${NC}"
    else
        echo -e "${RED}  BERHASIL - Response menunjukkan kerentanan!${NC}"
        echo "$RESPONSE" | head -c 200
    fi
    
    echo ""
    echo "Mencoba SQL Injection melalui proxy:"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/api/users?id=${PAYLOAD}")
    if [ "$STATUS" = "400" ] || [ "$STATUS" = "403" ]; then
        echo -e "${GREEN}  DIBLOKIR (HTTP $STATUS) - Proxy memfilter SQL Injection${NC}"
    else
        echo -e "${RED}  BERHASIL (HTTP $STATUS)${NC}"
    fi
    echo ""
}

test_ddos_resilience() {
    echo -e "${BLUE}[TEST 5] Ketahanan terhadap DDoS${NC}"
    REQUESTS=500
    
    echo "Menyerang backend langsung dengan $REQUESTS request:"
    START=$(date +%s.%N)
    SUCCESS_DIRECT=0
    FAIL_DIRECT=0
    
    for i in $(seq 1 $REQUESTS); do
        if curl -s -o /dev/null http://localhost:5000/api.php/users; then
            ((SUCCESS_DIRECT++))
        else
            ((FAIL_DIRECT++))
        fi
    done
    
    END=$(date +%s.%N)
    DURATION_DIRECT=$(echo "$END - $START" | bc)
    
    echo -e "  Sukses: $SUCCESS_DIRECT, Gagal: $FAIL_DIRECT"
    echo -e "  Waktu: ${DURATION_DIRECT}s"
    
    if [ $FAIL_DIRECT -gt $((REQUESTS / 10)) ]; then
        echo -e "${RED}  Backend langsung sangat RENTAN terhadap DDoS!${NC}"
    fi
    
    echo ""
    echo "Menyerang proxy dengan $REQUESTS request:"
    START=$(date +%s.%N)
    SUCCESS_PROXY=0
    FAIL_PROXY=0
    RATE_LIMITED=0
    
    for i in $(seq 1 $REQUESTS); do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/users)
        if [ "$STATUS" = "429" ]; then
            ((RATE_LIMITED++))
            ((SUCCESS_PROXY++))
        elif [ "$STATUS" = "200" ]; then
            ((SUCCESS_PROXY++))
        else
            ((FAIL_PROXY++))
        fi
    done
    
    END=$(date +%s.%N)
    DURATION_PROXY=$(echo "$END - $START" | bc)
    
    echo -e "  Sukses: $SUCCESS_PROXY, Gagal: $FAIL_PROXY, Rate Limited: $RATE_LIMITED"
    echo -e "  Waktu: ${DURATION_PROXY}s"
    
    if [ $FAIL_PROXY -eq 0 ]; then
        echo -e "${GREEN}  Proxy lebih TAHAN terhadap DDoS dengan rate limiting!${NC}"
    fi
    echo ""
}

test_information_leak() {
    echo -e "${BLUE}[TEST 6] Information Leakage${NC}"
    
    echo "Header response dari backend langsung:"
    curl -s -I http://localhost:5000/api.php/users | grep -E "Server|X-Powered-By|PHP"
    
    echo ""
    echo "Header response dari proxy:"
    curl -s -I http://localhost:8080/api/users | grep -E "Server|X-Powered-By"
    
    echo ""
}

main() {
    test_port_scanning
    test_sensitive_access
    test_config_exposure
    test_sql_injection
    test_ddos_resilience
    test_information_leak
    
    echo "======================================"
    echo -e "${GREEN}SIMULASI SELESAI${NC}"
    echo "======================================"
    echo ""
    echo "KESIMPULAN:"
    echo "1. Backend langsung (tanpa proxy) sangat rentan terhadap berbagai serangan"
    echo "2. Proxy Nginx memberikan lapisan keamanan tambahan:"
    echo "   - Filtering akses ke file sensitif"
    echo "   - Rate limiting untuk proteksi DDoS"
    echo "   - Sanitasi header untuk menyembunyikan informasi server"
    echo "   - Deteksi dan blokir pola serangan (SQL injection)"
    echo "3. Selalu gunakan reverse proxy untuk aplikasi production!"
}

main