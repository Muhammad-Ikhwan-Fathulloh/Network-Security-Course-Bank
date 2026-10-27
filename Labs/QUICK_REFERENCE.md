# ⚡ Quick Reference - Docker Commands & Lab Setup

## 🚀 Essential Docker Commands

### Start Lab
```bash
# Go to lab folder
cd ~/Labs/p5-l3

# Start all containers
docker-compose up -d

# Start specific container
docker-compose up -d attacker-l3 target-l3

# View running containers
docker-compose ps
```

### Access Containers
```bash
# Get shell access
docker-compose exec <service-name> bash
docker-compose exec attacker-l3 bash
docker-compose exec target-l3 bash

# Run command in container
docker-compose exec attacker-l3 ping 192.168.50.3
docker-compose exec monitor-l3 tcpdump -i eth0
```

### Check Status & Logs
```bash
# View logs
docker-compose logs <service>
docker-compose logs attacker-l3

# Follow logs in real-time
docker-compose logs -f monitor-l3

# Container stats
docker stats

# Inspect container
docker inspect <container-id>
```

### Stop & Cleanup
```bash
# Stop all containers (data preserved)
docker-compose stop

# Stop specific container
docker-compose stop attacker-l3

# Remove containers (data preserved)
docker-compose down

# Remove containers AND volumes
docker-compose down -v

# Remove all Docker resources
docker system prune -a
```

---

## 🧪 Lab Setup Cheat Sheet

### Pertemuan 4: Wireless

```bash
# Setup
cd Labs && mkdir p4-wireless && cd p4-wireless
cp ../docker-compose-p4.yml .
docker-compose up -d

# Access Kali
docker-compose exec kali-wireless-lab bash

# Key commands
aircrack-ng --version
airodump-ng wlan0mon
aireplay-ng --help
airbase-ng --help

# Cleanup
docker-compose down
```

### Pertemuan 5: L3 Security

```bash
# Setup
cd Labs && mkdir p5-l3 && cd p5-l3
cp ../docker-compose-p5.yml .
docker-compose up -d

# Terminal 1: Monitor
docker-compose exec monitor-l3 bash
tcpdump -i eth0 -n icmp

# Terminal 2: Attacker
docker-compose exec attacker-l3 bash
ping 192.168.50.255  # Broadcast
python3 /tmp/scripts/smurf.py

# Terminal 3: Target
docker-compose exec target-l3 bash
watch 'netstat -an | wc -l'

# Cleanup
docker-compose down
```

### Pertemuan 6: L4 Security

```bash
# Setup
cd Labs && mkdir p6-l4 && cd p6-l4
cp ../docker-compose-p6.yml .
docker-compose up -d

# Terminal 1: Monitor packets
docker-compose exec monitor-l4 bash
tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0'

# Terminal 2: Monitor server state
docker-compose exec target-webserver bash
watch -n 1 "netstat -atn | grep SYN_RECV | wc -l"

# Terminal 3: Launch attack
docker-compose exec attacker-l4 bash
hping3 -S --flood --rand-source -p 80 192.168.60.3

# Cleanup
docker-compose down
```

### Pertemuan 7: DNS Security

```bash
# Setup
cd Labs && mkdir p7-dns && cd p7-dns
cp ../docker-compose-p7.yml .
docker-compose up -d

# Terminal 1: Monitor DNS
docker-compose exec monitor-dns bash
tcpdump -i eth0 -n port 53 -A

# Terminal 2: Poisoning
docker-compose exec attacker-dns bash
dnschef --fakeip 192.168.70.2 --fakedomains example.com \
        --interface 192.168.70.2 --nameserver 192.168.70.3

# Terminal 3: Client queries
docker-compose exec client-dns bash
dig @192.168.70.3 example.com

# Cleanup
docker-compose down
```

---

## 🔧 Common Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs <service>

# Rebuild container
docker-compose up -d --build

# Remove and restart
docker-compose down
docker-compose up -d
```

### Network issues
```bash
# Check network
docker network ls
docker network inspect <network>

# Check container IP
docker-compose exec <service> ip addr show

# Test connectivity
docker-compose exec service1 ping service2
```

### Permission denied
```bash
# Linux - add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or use sudo
sudo docker-compose up -d
```

### Port already in use
```bash
# Find what's using the port
netstat -tuln | grep <port>

# Kill the process or
# Change port in docker-compose.yml
```

---

## 📊 Network Addresses Cheat Sheet

| Lab | Service | IP | Port |
|-----|---------|----|----|
| **P4** | kali-wireless | 192.168.100.2 | - |
| | wifi-ap-target | 192.168.100.3 | - |
| **P5** | attacker-l3 | 192.168.50.2 | - |
| | target-l3 | 192.168.50.3 | - |
| | dhcp-server | 192.168.50.4 | 67/68 |
| **P6** | attacker-l4 | 192.168.60.2 | - |
| | target-webserver | 192.168.60.3 | 80 |
| | target-udp | 192.168.60.4 | 5353/UDP |
| **P7** | attacker-dns | 192.168.70.2 | - |
| | dns-resolver | 192.168.70.3 | 53 |
| | dns-auth | 192.168.70.4 | 5353 |
| | web-target | 192.168.70.5 | 80 |
| | client-dns | 192.168.70.6 | - |

---

## 📝 Common Tools in Containers

### Kali Containers
```bash
# Available tools
aircrack-ng / airbase-ng / aireplay-ng  # Wireless
hping3 / nmap / netcat                  # Network
tcpdump / wireshark / tshark            # Packet analysis
scapy / python3                         # Scripting
dnschef / dig / nslookup                # DNS tools
```

### Ubuntu Containers
```bash
# Install additional tools
apt-get update
apt-get install -y <package>

# Common useful packages
apt-get install -y tcpdump net-tools iproute2 curl wget
```

---

## 🎯 Quick Lab Workflow

```bash
# 1. Preparation
cd Labs/p5-l3
docker-compose up -d
sleep 5  # Wait for network ready

# 2. Open 3 terminals
# Terminal 1: Monitor
docker-compose exec monitor-l3 bash
tcpdump -i eth0 -n

# Terminal 2: Target
docker-compose exec target-l3 bash
watch 'netstat -an | grep ESTABLISHED'

# Terminal 3: Attacker
docker-compose exec attacker-l3 bash
# Run attack here

# 3. Analyze
# Watch tcpdump output in Terminal 1
# Monitor netstat in Terminal 2
# Control attack in Terminal 3

# 4. Cleanup
docker-compose down
```

---

## 💾 Saving Lab Results

```bash
# Create backup folder
mkdir -p ~/backups/lab-results

# Copy PCAP files before cleanup
cp p5-l3/captures/* ~/backups/lab-results/

# Copy container logs
docker-compose logs > ~/backups/lab-results/logs.txt

# Save analysis
docker-compose exec monitor-l3 tcpdump -r capture.pcap > ~/backups/analysis.txt
```

---

## 🔍 Monitoring Techniques

### Terminal multiplexing with tmux (optional)
```bash
# Open 3 panes in one window
tmux new-session -s lab -d
tmux send-keys -t lab "docker-compose exec monitor-l3 bash" Enter
tmux split-window -h -t lab
tmux send-keys -t lab "docker-compose exec target-l3 bash" Enter
tmux split-window -v -t lab
tmux send-keys -t lab "docker-compose exec attacker-l3 bash" Enter
tmux attach -t lab
```

### Watch real-time metrics
```bash
# Network connections
watch -n 1 "netstat -atn | wc -l"

# TCP SYN_RECV
watch -n 1 "netstat -atn | grep SYN_RECV | wc -l"

# Network traffic
watch -n 1 "ifconfig eth0"

# CPU/Memory
watch -n 1 "free -h && ps aux --sort=-%cpu | head -5"
```

---

## 🎓 Learning Progression

1. **Day 1: Learn Docker Basics**
   ```bash
   docker --help
   docker ps
   docker-compose --help
   ```

2. **Day 2: Run First Lab**
   - Follow P5 step-by-step
   - Understand container networking
   - Practice basic commands

3. **Day 3-4: Run All Labs**
   - P4: Wireless
   - P5: L3
   - P6: L4
   - P7: DNS

4. **Day 5+: Advanced**
   - Modify docker-compose.yml
   - Add custom services
   - Write custom attack scripts
   - Combine multiple labs

---

**Need help?** Check `README.md` for detailed guides!
