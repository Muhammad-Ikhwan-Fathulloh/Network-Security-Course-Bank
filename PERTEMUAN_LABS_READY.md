# ✅ Pertemuan Labs - Ready to Use

**Status:** ✅ All Labs Prepared and Ready  
**Date:** 2025-10-27

---

## 📦 What's Included

Setiap pertemuan (4-7) sekarang memiliki folder siap pakai dengan struktur lengkap untuk docker-based labs.

### Folder Structure

```
Pertemuan4/                    ✅ Wireless Security
├── docker-compose.yml
├── README.md
├── INDEX.md
├── captures/
├── wordlists/
├── configs/
└── scripts/

Pertemuan5/                    ✅ L3 Security
├── docker-compose.yml
├── README.md
├── INDEX.md
├── scripts/
│   └── smurf_attack.py       📝 Ready to use
├── captures/
└── configs/

Pertemuan6/                    ✅ L4 Security
├── docker-compose.yml
├── README.md
├── INDEX.md
├── captures/
├── scripts/
└── configs/

Pertemuan7/                    ✅ DNS Security
├── docker-compose.yml
├── README.md
├── INDEX.md
├── scripts/
│   └── dns_spoof.py          📝 Ready to use
├── captures/
└── configs/
```

---

## 🚀 How to Use

### Start Any Lab (3 Steps)

```bash
# 1. Go to Pertemuan folder
cd Pertemuan4  # or P5, P6, P7

# 2. Start containers
docker-compose up -d

# 3. Access attacker/lab
docker-compose exec <service-name> bash
```

### For Example: Pertemuan 5 (L3 Security)

```bash
cd Pertemuan5

# Start lab
docker-compose up -d

# Monitor in Terminal 1
docker-compose exec monitor-l3 bash
tcpdump -i eth0 -n icmp

# Attack in Terminal 2
docker-compose exec attacker-l3 bash
python3 scripts/smurf_attack.py 192.168.50.3 192.168.50.255 10

# Cleanup
docker-compose down
```

---

## 📋 File Reference

### Each Pertemuan Has:

#### 1. docker-compose.yml
- Pre-configured Docker setup
- All services defined
- Networks and volumes configured
- Ready to `docker-compose up -d`

#### 2. README.md
- Quick start guide
- Lab workflow
- Common commands
- Troubleshooting

#### 3. INDEX.md
- Folder structure overview
- What's included
- Quick reference
- Lab topology diagram

#### 4. Folders
```
captures/  → Save PCAP files here
scripts/   → Attack scripts (some pre-made)
configs/   → Configuration files
```

---

## 🎯 Pre-made Scripts

### Pertemuan 5: smurf_attack.py
```bash
cd Pertemuan5

docker-compose exec attacker-l3 bash
python3 scripts/smurf_attack.py <target_ip> <broadcast_ip> [duration] [interval]

# Example:
python3 scripts/smurf_attack.py 192.168.50.3 192.168.50.255 10 0.1
```

### Pertemuan 7: dns_spoof.py
```bash
cd Pertemuan7

docker-compose exec attacker-dns bash
python3 scripts/dns_spoof.py <fake_ip> [domains] [interface]

# Example:
python3 scripts/dns_spoof.py 192.168.70.2 example.com
```

---

## 📖 Learning Path

### Day 1: Pertemuan 4 (Wireless)
```bash
cd Pertemuan4
docker-compose up -d

# Read: Pertemuan4.md sections 1-3 (theory)
# Then: Follow Pertemuan4.md section 4+ (hands-on)
# Lab: airodump-ng, deauth, WPA2 cracking
```

### Day 2: Pertemuan 5 (L3)
```bash
cd Pertemuan5
docker-compose up -d

# Read: Pertemuan5.md sections 1-3 (theory)
# Then: Follow Pertemuan5.md section 4+ (hands-on)
# Lab: SMURF, DHCP starvation, ICMP redirect
```

### Day 3: Pertemuan 6 (L4)
```bash
cd Pertemuan6
docker-compose up -d

# Read: Pertemuan6.md sections 1-3 (theory)
# Then: Follow Pertemuan6.md section 5+ (hands-on)
# Lab: SYN flood, TCP state, mitigation
```

### Day 4: Pertemuan 7 (DNS)
```bash
cd Pertemuan7
docker-compose up -d

# Read: Pertemuan7.md sections 1-3 (theory)
# Then: Follow Pertemuan7.md section 5+ (hands-on)
# Lab: DNS spoofing, poisoning, exfiltration
```

---

## 🔧 Common Workflows

### Multi-Terminal Setup (Recommended)

```bash
# Terminal 1: Monitor
docker-compose exec monitor-l3 bash
tcpdump -i eth0 -n

# Terminal 2: Target
docker-compose exec target-l3 bash
watch -n 1 'netstat -an | wc -l'

# Terminal 3: Attacker
docker-compose exec attacker-l3 bash
python3 scripts/smurf_attack.py 192.168.50.3 192.168.50.255 10
```

### Save & Analyze Results

```bash
# In monitor terminal
tcpdump -i eth0 -n -w capture.pcap

# Copy to host
docker cp monitor-l3:/tmp/capture.pcap captures/

# Open in Wireshark
wireshark captures/capture.pcap
```

---

## 📊 Lab Comparison

| Lab | Pertemuan | Containers | Focus | Difficulty |
|-----|-----------|-----------|-------|-----------|
| P4 | Wireless | 3 | WPA2, Aircrack | Medium |
| P5 | L3 | 4 | ICMP, Spoofing | Easy |
| P6 | L4 | 4 | TCP/UDP, DoS | Medium |
| P7 | DNS | 6 | DNS, Spoofing | Easy |

---

## 💾 Backup Strategy

```bash
# After each lab, backup results
mkdir -p ~/backups/P5
cp Pertemuan5/captures/* ~/backups/P5/
cp Pertemuan5/scripts/* ~/backups/P5/
docker-compose logs > ~/backups/P5/lab.log
```

---

## 🔍 Verification Checklist

For each Pertemuan folder:
- [x] docker-compose.yml exists and valid
- [x] README.md with quick start
- [x] INDEX.md with overview
- [x] captures/ folder for PCAP files
- [x] scripts/ folder with examples
- [x] configs/ folder for config files
- [x] All referenced files in place

**All ✅ Verified**

---

## 📚 Documentation Structure

```
Network-Security-Course-Bank/
├── Pertemuan4.md (Theory + hands-on)
├── Pertemuan5.md (Theory + hands-on)
├── Pertemuan6.md (Theory + hands-on)
├── Pertemuan7.md (Theory + hands-on)
│
├── Pertemuan4/ ✅ Lab folder
│   ├── docker-compose.yml
│   ├── README.md
│   ├── INDEX.md
│   └── (captures, scripts, configs folders)
│
├── Pertemuan5/ ✅ Lab folder
│   ├── docker-compose.yml
│   ├── README.md
│   ├── INDEX.md
│   ├── scripts/smurf_attack.py
│   └── (captures, scripts, configs folders)
│
├── Pertemuan6/ ✅ Lab folder
│   ├── docker-compose.yml
│   ├── README.md
│   ├── INDEX.md
│   └── (captures, scripts, configs folders)
│
├── Pertemuan7/ ✅ Lab folder
│   ├── docker-compose.yml
│   ├── README.md
│   ├── INDEX.md
│   ├── scripts/dns_spoof.py
│   └── (captures, scripts, configs folders)
│
├── Labs/
│   ├── README.md (Comprehensive guide)
│   ├── QUICK_REFERENCE.md (Cheat sheet)
│   ├── docker-compose-p4.yml
│   ├── docker-compose-p5.yml
│   ├── docker-compose-p6.yml
│   └── docker-compose-p7.yml
│
└── Supporting files
    ├── START_HERE.md
    ├── RELEASE_NOTES.md
    ├── IMPROVEMENTS_SUMMARY.md
    ├── SETUP_CHECKLIST.md
    └── PERTEMUAN_LABS_READY.md (this file)
```

---

## 🎓 What Each Lab Teaches

### Pertemuan 4: Wireless Security 📡
- WPA2 security mechanisms
- 4-way handshake process
- Monitor mode and scanning
- Handshake capture
- Dictionary attacks
- Deauthentication attacks
- Evil Twin (rogue AP) attacks

### Pertemuan 5: Layer 3 Security 🌐
- ICMP protocol and vulnerabilities
- IP spoofing techniques
- SMURF attacks and amplification
- DHCP starvation
- ICMP redirect attacks
- Network reconnaissance
- Packet crafting with Scapy

### Pertemuan 6: Layer 4 Security 🔄
- TCP three-way handshake
- SYN flood mechanism
- Server resource exhaustion
- TCP state machine
- UDP amplification attacks
- Mitigation strategies
- Real-time monitoring

### Pertemuan 7: DNS Security 🌐
- DNS resolution process
- DNS record types
- Cache and TTL
- DNS spoofing techniques
- Cache poisoning attacks
- DNS exfiltration
- Zone transfer vulnerabilities
- DNSSEC basics

---

## ✨ Key Features

✅ **Pre-configured Docker Compose files** - No setup needed  
✅ **Ready-to-use attack scripts** - smurf_attack.py, dns_spoof.py  
✅ **Organized folder structure** - captures, scripts, configs  
✅ **Comprehensive documentation** - README.md, INDEX.md for each  
✅ **Quick start guides** - Get running in 30 seconds  
✅ **Example workflows** - Multi-terminal setups included  
✅ **Backup strategies** - Save results for analysis  

---

## 🎯 Quick Start (Pick Any Lab)

```bash
# Example: Start Pertemuan 5 lab
cd Pertemuan5
docker-compose up -d

# Verify
docker-compose ps

# Start hands-on
# Read: Pertemuan5.md for detailed guide
# Then: docker-compose exec attacker-l3 bash
```

---

## 📞 Troubleshooting

For any issues:
1. **Check:** `Pertemuan<X>/README.md` troubleshooting section
2. **Check:** `Pertemuan<X>/INDEX.md` for overview
3. **Check:** `Labs/README.md` for detailed guide
4. **Check:** `Labs/QUICK_REFERENCE.md` for commands
5. **Check:** logs with `docker-compose logs`

---

## 🎉 You're All Set!

All labs are prepared and ready to use. Choose your first pertemuan and start learning!

```bash
# Start learning today
cd Pertemuan5  # Best for beginners
docker-compose up -d
# Follow Pertemuan5.md for hands-on guide
```

---

**Status:** ✅ All Pertemuan labs ready for immediate use
**Total Labs:** 4 (P4-P7)
**Total Containers:** 17
**Pre-made Scripts:** 2
**Documentation Pages:** 6 (README + INDEX per lab + master docs)

**Happy Learning! 🚀**
