FROM kalilinux/kali-rolling
RUN apt-get update && \
    apt-get install -y --no-install-recommends hping3 dnsutils xxd dsniff aircrack-ng python3 python3-scapy netcat-openbsd tcpdump curl && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /work
CMD ["sleep", "infinity"]
