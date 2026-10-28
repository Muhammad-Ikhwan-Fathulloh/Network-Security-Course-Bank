# 📡 Pertemuan 4: Wireless Security Lab

Lab environment untuk praktik WPA2 cracking, deauthentication attack, dan evil twin attack.

---

## 🚀 Quick Start

### Prerequisites
- Docker dan Docker Compose terinstall
- Repository di-clone: `https://github.com/Muhammad-Ikhwan-Fathulloh/Network-Security-Course-Bank`
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

# Start Pertemuan 4 lab
docker-compose -f docker-compose-p4.yml up -d

# Verifikasi
docker-compose -f docker-compose-p4.yml ps

# Akses Kali container
docker-compose -f docker-compose-p4.yml exec kali-wireless-lab bash
```

### Cleanup
```bash
docker-compose -f docker-compose-p4.yml down
```

---

## 📋 Lab Structure

```
Labs/
├── docker-compose-p4.yml    # Pertemuan 4 config
├── docker-compose-p5.yml    # Pertemuan 5 config
├── docker-compose-p6.yml    # Pertemuan 6 config
├── docker-compose-p7.yml    # Pertemuan 7 config
├── README.md               # Main guide
└── QUICK_REFERENCE.md      # Commands

Pertemuan4/
├── README.md (this file)
├── INDEX.md
├── captures/        # Untuk .cap files
├── wordlists/       # Untuk rockyou.txt
├── configs/         # Untuk AP config
└── scripts/         # Untuk custom scripts
```

---

## 🐳 Container Services

| Container | IP | Role |
|-----------|----|----|
| kali-wireless-lab | 192.168.100.2 | Attacker (aircrack-ng tools) |
| monitor-wireless | 192.168.100.3 | Monitoring (tcpdump) |

---

## 📖 Lab Workflow

### 1. Monitor Jaringan
```bash
docker-compose -f docker-compose-p4.yml exec kali-wireless-lab bash

# Check aircrack-ng installed
aircrack-ng --help

# Scan WiFi networks
airodump-ng wlan0mon
```

### 2. Tangkap Handshake
```bash
# Fokus ke target
airodump-ng --bssid <BSSID> -c <channel> -w ../Pertemuan4/captures/capture wlan0mon
```

### 3. Crack Password
```bash
# Setelah handshake tertangkap
cd ../Pertemuan4
aircrack-ng captures/capture-01.cap -w wordlists/rockyou.txt
```

---

## 🔧 Common Commands

### Setup Wordlist
```bash
cd Pertemuan4/wordlists
cat > custom.txt << EOF
password123
wifipassword
router12345
EOF
```

### View Captures
```bash
ls -la Pertemuan4/captures/
```

---

## 📞 Documentation

- **Theory & Hands-on:** `Pertemuan4.md`
- **Lab Overview:** `Pertemuan4/INDEX.md`
- **Main Guide:** `Labs/README.md`
- **Quick Reference:** `Labs/QUICK_REFERENCE.md`

---

## 🎓 Learning Outcomes

- ✅ WPA2 security mechanisms
- ✅ 4-way handshake process
- ✅ Wireless network scanning
- ✅ Handshake capture techniques
- ✅ Dictionary attacks
- ✅ Deauthentication attacks
- ✅ Evil Twin attacks

---

## 📚 Repository
GitHub: https://github.com/Muhammad-Ikhwan-Fathulloh/Network-Security-Course-Bank

---

**Next:** Baca `Pertemuan4.md` untuk teori lengkap dan detailed hands-on guide.
