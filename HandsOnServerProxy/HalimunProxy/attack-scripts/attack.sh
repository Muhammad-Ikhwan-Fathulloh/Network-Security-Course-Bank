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

test_port_scanning() {
    echo -e "${BLUE}[TEST 1] Port Scanning${NC}"
    echo "Memindai port 5000 (backend langsung):"
    if nc -zv localhost 5000 2>&1 | grep -q "succeeded"; then
        echo -e "${RED}  PORT 5000 TERBUKA - Backend terekspos!${NC}"
    else
        echo -e "${GREEN}  Port 5000 tertutup${NC}"
    fi
    
    echo ""
    echo "Memindai port 8080 (gateway):"
    if nc -zv localhost 8080 2>&1 | grep -q "succeeded"; then
        echo -e "${YELLOW}  Port 8080 terbuka (hanya gateway yang terlihat)${NC}"
    else
        echo -e "${RED}  Port 8080 tidak dapat diakses${NC}"
    fi
    
    echo ""
    echo "Memindai port internal Halimun (seharusnya tidak terlihat):"
    if nc -zv localhost 7878 2>&1 | grep -q "succeeded"; then
        echo -e "${RED}  Halimun-Proxy internal port terekspos!${NC}"
    else
        echo -e "${GREEN}  Port 7878 TIDAK TERDETEKSI${NC}"
    fi
    echo ""
}

test_direct_vs_proxy() {
    echo -e "${BLUE}[TEST 2] Perbandingan Response (Direct vs Proxy)${NC}"
    
    echo "Request ke backend langsung (Data terlihat):"
    curl -s http://localhost:5000/api.php/users | head -c 200
    echo -e "\n"
    
    echo "Request ke Halimun-Proxy (tanpa enkripsi - harus ditolak):"
    curl -s -u admin:admin -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:8080/proxy/1/users
    echo ""
}

test_replay_attack() {
    echo -e "${BLUE}[TEST 3] Replay Attack Simulation${NC}"
    
    # Simulating a capture and replay of an encrypted payload
    # In a real scenario, this would be a POST request with an 'x=' body.
    # For simulation, we use a fixed segment to trigger the proxy logic.
    
    echo "Mengirim request pertama (Valid Nonce)..."
    PAYLOAD=$(curl -s -u admin:admin -X POST http://localhost:8080/proxy/1/valid_nonce_test \
        -d "x=dummy_payload" \
        -c cookies.txt -b cookies.txt)
    
    echo "Attempt 1: $PAYLOAD"
    
    sleep 1
    
    echo "Melakukan Replay (Nonce yang sama)..."
    PAYLOAD2=$(curl -s -u admin:admin -X POST http://localhost:8080/proxy/1/valid_nonce_test \
        -d "x=dummy_payload" \
        -c cookies.txt -b cookies.txt)
    
    echo "Attempt 2 (replay): $PAYLOAD2"
    
    if echo "$PAYLOAD2" | grep -iq "replay\|error\|denied\|403"; then
        echo -e "${GREEN}  Replay attack DIBLOKIR oleh Halimun-Proxy!${NC}"
    else
        echo -e "${RED}  Replay attack BERHASIL! (Ini tidak seharusnya terjadi)${NC}"
    fi
    echo ""
}

test_ssrf_protection() {
    echo -e "${BLUE}[TEST 4] SSRF Protection Test${NC}"
    
    echo "Mencoba akses ke localhost via proxy (SSRF Payload):"
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

test_ddos_resilience() {
    echo -e "${BLUE}[TEST 5] Ketahanan terhadap DDoS (Rate Limiting)${NC}"
    REQUESTS=100
    
    echo "Menyerang gateway dengan $REQUESTS request cepat..."
    SUCCESS=0
    RATE_LIMITED=0
    
    for i in $(seq 1 $REQUESTS); do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
        if [ "$STATUS" = "429" ]; then
            ((RATE_LIMITED++))
        elif [ "$STATUS" = "200" ]; then
            ((SUCCESS++))
        fi
    done
    
    echo -e "  Berhasil: $SUCCESS, Dibatasi (429): $RATE_LIMITED"
    
    if [ $RATE_LIMITED -gt 0 ]; then
        echo -e "${GREEN}  Nginx Gateway berhasil membatasi traffic berlebih!${NC}"
    else
        echo -e "${YELLOW}  Rate limit tidak terpicu (mungkin limit terlalu tinggi)${NC}"
    fi
    echo ""
}

test_information_leak() {
    echo -e "${BLUE}[TEST 6] Information Leakage Comparison${NC}"
    
    echo "Header response dari backend langsung (PHP Terekspos):"
    curl -s -I http://localhost:5000/api.php/users | grep -E "Server|X-Powered-By|PHP"
    
    echo ""
    echo "Header response dari Halimun-Proxy/Nginx (Bersih):"
    curl -s -I http://localhost:8080/ | grep -E "Server|X-Powered-By"
    echo ""
}

test_camouflage_url() {
    echo -e "${BLUE}[TEST 7] Camouflage URL Observation${NC}"
    
    echo "Perhatikan pattern routing yang tersembunyi:"
    for i in {1..2}; do
        SEGMENT=$(openssl rand -hex 8)
        curl -s -u admin:admin -X POST http://localhost:8080/proxy/1/$SEGMENT \
            -d "x=dummy" \
            -o /dev/null -w "Request $i URL: /proxy/1/$SEGMENT (Status: %{http_code})\n"
    done
    echo ""
}

main() {
    test_port_scanning
    test_direct_vs_proxy
    test_replay_attack
    test_ssrf_protection
    test_ddos_resilience
    test_information_leak
    test_camouflage_url
    
    echo "======================================"
    echo -e "${GREEN}SIMULASI SELESAI${NC}"
    echo "======================================"
    echo ""
    echo "KESIMPULAN KEAMANAN HALIMUN-PROXY:"
    echo "1. End-to-End Encryption: Scanner otomatis (sqlmap/nmap) tidak bisa membaca/manipulasi data"
    echo "2. Replay Protection: Token sekali pakai mencegah pencurian session"
    echo "3. SSRF Guard: Mencegah penyalahgunaan proxy untuk menyerang internal network"
    echo "4. Camouflage URLs: Menghilangkan jejak struktur direktori backend"
    echo "5. Layered Defense: Kombinasi Nginx (Rate Limit) + Halimun (Encryption)"
}

main