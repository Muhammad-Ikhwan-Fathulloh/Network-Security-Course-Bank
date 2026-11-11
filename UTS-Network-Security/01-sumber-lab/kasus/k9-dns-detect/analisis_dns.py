"""Kasus 9: deteksi kemungkinan DNS exfiltration dari log dnsmasq.

Pemakaian:
    python3 analisis_dns.py dns.log

Skrip menghitung panjang label dan jumlah query per domain induk,
lalu menandai label yang panjang atau berisi hanya karakter hex.
"""
import re
import sys
from collections import Counter

PAT = re.compile(r"query\[\w+\] (\S+) from")
BATAS_PANJANG_LABEL = 30

jumlah_domain = Counter()
mencurigakan = []

with open(sys.argv[1], encoding="utf-8", errors="ignore") as f:
    for baris in f:
        m = PAT.search(baris)
        if not m:
            continue
        nama = m.group(1).rstrip(".")
        bagian = nama.split(".")
        domain_induk = ".".join(bagian[-2:])
        jumlah_domain[domain_induk] += 1
        label = bagian[0]
        if len(label) > BATAS_PANJANG_LABEL and re.fullmatch(r"[0-9a-fA-F]+", label):
            mencurigakan.append((len(label), nama))

print("Jumlah query per domain induk:")
for domain, n in jumlah_domain.most_common():
    print(f"  {domain}: {n}")

print("\nQuery mencurigakan (label panjang berisi hex):")
for panjang, nama in mencurigakan:
    print(f"  panjang={panjang}  {nama}")
