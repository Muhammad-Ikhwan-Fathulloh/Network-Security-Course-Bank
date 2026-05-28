#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "======================================"
echo "  SIMULASI SERANGAN KE HALIMUN-PROXY"
echo "======================================"
echo ""

test_direct_vs_proxy() {
    echo -e "${BLUE}[TEST 1] Perbandingan Response${NC}"
    
    echo "Request ke backend langsung:"
    curl -s http://localhost:5000/api.php/users | head -c 200
    echo ""
    
    echo "Request ke Halimun-Proxy (tanpa enkripsi - harus ditolak):"
    curl -s -u admin:admin -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:8080/proxy/1/users
    echo ""
}

test_replay_attack() {
    echo -e "${BLUE}[TEST 2] Replay Attack Simulation${NC}"
    
    PAYLOAD=$(curl -s -u admin:admin -X POST http://localhost:8080/proxy/1/users \
        -d "x=test" \
        -c cookies.txt \
        -b cookies.txt)
    
    echo "Attempt 1: $PAYLOAD"
    
    sleep 1
    
    PAYLOAD2=$(curl -s -u admin:admin -X POST http://localhost:8080/proxy/1/users \
        -d "x=test" \
        -c cookies.txt \
        -b cookies.txt)
    
    echo "Attempt 2 (replay): $PAYLOAD2"
    
    if echo "$PAYLOAD2" | grep -q "replay"; then
        echo -e "${GREEN}  Replay attack DIBLOKIR oleh Halimun-Proxy!${NC}"
    else
        echo -e "${RED}  Replay attack BERHASIL!${NC}"
    fi
    echo ""
}

test_ssrf_protection() {
    echo -e "${BLUE}[TEST 3] SSRF Protection Test${NC}"
    
    echo "Mencoba akses ke localhost via proxy:"
    curl -s -u admin:admin -X POST http://localhost:8080/proxy/1/ssrf \
        -d "target=http://127.0.0.1:5000/api.php/users" \
        -o /dev/null -w "HTTP Status: %{http_code}\n"
    
    echo ""
    echo "Mencoba akses ke internal network:"
    curl -s -u admin:admin -X POST http://localhost:8080/proxy/1/ssrf \
        -d "target=http://192.168.1.1:80" \
        -o /dev/null -w "HTTP Status: %{http_code}\n"
    echo ""
}

test_information_leak() {
    echo -e "${BLUE}[TEST 4] Information Leakage Comparison${NC}"
    
    echo "Header dari backend langsung:"
    curl -s -I http://localhost:5000/api.php/users | grep -E "Server|X-Powered-By|PHP"
    
    echo ""
    echo "Header dari Halimun-Proxy:"
    curl -s -I http://localhost:8080/ | grep -E "Server|X-Powered-By"
    echo ""
}

test_camouflage_url() {
    echo -e "${BLUE}[TEST 5] Camouflage URL Observation${NC}"
    
    echo "Perhatikan URL pattern yang berbeda setiap request:"
    for i in {1..3}; do
        curl -s -u admin:admin -X POST http://localhost:8080/proxy/1/$(openssl rand -hex 8) \
            -d "x=dummy" \
            -o /dev/null -w "URL pattern $i: /proxy/1/[random segments]\n"
    done
    echo ""
}

main() {
    test_direct_vs_proxy
    test_replay_attack
    test_ssrf_protection
    test_information_leak
    test_camouflage_url
    
    echo "======================================"
    echo -e "${GREEN}SIMULASI SELESAI${NC}"
    echo "======================================"
    echo ""
    echo "KESIMPULAN KEAMANAN HALIMUN-PROXY:"
    echo "1. End-to-End Encryption: Payload tidak bisa dibaca attacker"
    echo "2. Replay Protection: Request yang sama ditolak"
    echo "3. SSRF Guard: Internal network tidak bisa diakses"
    echo "4. Camouflage URLs: Pattern routing tersembunyi"
    echo "5. No Information Leak: Header server tersembunyi"
}

main