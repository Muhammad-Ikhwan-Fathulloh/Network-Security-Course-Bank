FROM alpine:3.20
RUN apk add --no-cache dnsmasq
EXPOSE 53/udp 53/tcp
CMD ["dnsmasq", "-k", "-d", "--no-resolv", "--log-queries", "--log-facility=-", "--address=/exfil.lab/10.0.0.99"]
