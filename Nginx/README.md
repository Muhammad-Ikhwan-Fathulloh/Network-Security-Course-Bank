# Step by Step Konfigurasi Nginx Lengkap dengan Proteksi Bot

## Prasyarat
- Server Linux (Ubuntu/Debian/CentOS)
- Nginx sudah terinstall
- Akses root atau sudo

## Step 1: Persiapan Awal

### 1.1 Update sistem dan install Nginx (jika belum)
```bash
# Untuk Ubuntu/Debian
sudo apt update
sudo apt install nginx -y

# Untuk CentOS/RHEL
sudo yum install nginx -y
```

### 1.2 Cek status Nginx
```bash
sudo systemctl status nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

### 1.3 Backup konfigurasi default
```bash
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
```

## Step 2: Buat Struktur Direktori dan File

### 2.1 Buat direktori untuk website
```bash
# Buat direktori root website
sudo mkdir -p /var/www/yourdomain.com/html
sudo mkdir -p /var/www/yourdomain.com/logs

# Set permission
sudo chown -R $USER:$USER /var/www/yourdomain.com/html
sudo chmod -R 755 /var/www/yourdomain.com
```

### 2.2 Buat file index.html contoh
```bash
sudo nano /var/www/yourdomain.com/html/index.html
```

Isi dengan:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Website Protected</title>
</head>
<body>
    <h1>Welcome to Protected Website</h1>
    <p>This website is protected against bots and malicious scans.</p>
</body>
</html>
```

## Step 3: Konfigurasi Nginx

### 3.1 Buat file konfigurasi baru
```bash
sudo nano /etc/nginx/sites-available/yourdomain.com
```

### 3.2 Copy konfigurasi lengkap
Paste konfigurasi berikut (sesuaikan domain dan path):

```nginx
# Rate limiting zone
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=login_limit:10m rate=5r/m;
limit_conn_zone $binary_remote_addr zone=conn_limit:10m;

# Block User-Agent
map $http_user_agent $blocked_ua {
    default 0;
    ~*(PostmanRuntime|curl|insomnia|python-requests|httpclient|libwww|wget|nmap|nikto|burpsuite|owasp|zaproxy|sqlmap|rest-client|httpie|aria2|openvas|masscan|nessus) 1;
    ~*(Go-http-client|Java|Python-urllib|Scrapy|Hydra|Medusa|THC|Brutus|JohnTheRipper) 1;
}

# Redirect HTTP ke HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

# Server HTTPS utama
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    # Root direktori
    root /var/www/yourdomain.com/html;
    index index.html index.htm index.php;
    
    # Logging
    access_log /var/www/yourdomain.com/logs/access.log;
    error_log /var/www/yourdomain.com/logs/error.log;
    
    # SSL (akan diisi nanti)
    # ssl_certificate /etc/nginx/ssl/cert.pem;
    # ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Block User-Agent berbahaya
    if ($blocked_ua) {
        return 403;
    }
    
    # Block tanpa User-Agent
    if ($http_user_agent = "") {
        return 403;
    }
    
    # Rate limiting
    limit_req zone=api_limit burst=20 nodelay;
    limit_conn conn_limit 10;
    
    # Block metode HTTP berbahaya
    if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|PATCH)$) {
        return 405;
    }
    
    # Proteksi SQL Injection
    set $blocked 0;
    if ($query_string ~* "(\%27)|(\')|(\-\-)|(union.*select)|(select.*from)|(drop.*table)") {
        set $blocked 1;
    }
    if ($query_string ~* "(\../)|(\.\.\/)") {
        set $blocked 1;
    }
    if ($blocked = 1) {
        return 403;
    }
    
    # Block file tersembunyi
    location ~ /\. {
        deny all;
        return 403;
    }
    
    # Block file config
    location ~* \.(ini|conf|log|bak|sql|sh|env)$ {
        deny all;
        return 403;
    }
    
    # Rate limit khusus login
    location /login {
        limit_req zone=login_limit burst=2 nodelay;
        limit_req_status 429;
    }
    
    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Error pages
    error_page 403 /403.html;
    error_page 404 /404.html;
    
    location = /403.html {
        internal;
        root /usr/share/nginx/html;
    }
}
```

## Step 4: Aktivasi Konfigurasi

### 4.1 Enable site
```bash
# Buat symbolic link
sudo ln -s /etc/nginx/sites-available/yourdomain.com /etc/nginx/sites-enabled/

# Hapus default site (opsional)
sudo rm /etc/nginx/sites-enabled/default
```

### 4.2 Test konfigurasi
```bash
# Test syntax Nginx
sudo nginx -t
```

Jika berhasil akan muncul:
```
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### 4.3 Reload Nginx
```bash
sudo systemctl reload nginx
```

## Step 5: Setup SSL Certificate (Opsional tapi direkomendasikan)

### 5.1 Install Certbot
```bash
# Ubuntu/Debian
sudo apt install certbot python3-certbot-nginx -y

# CentOS/RHEL
sudo yum install certbot python3-certbot-nginx -y
```

### 5.2 Dapatkan SSL certificate
```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

Ikuti wizard:
- Masukkan email
- Setujui terms of service
- Pilih redirect HTTP ke HTTPS (option 2)

### 5.3 Auto-renewal SSL
```bash
sudo certbot renew --dry-run
```

## Step 6: Testing Konfigurasi

### 6.1 Test dengan curl (seharusnya diblokir)
```bash
# Test dengan curl - seharusnya 403
curl -A "curl/7.68.0" https://yourdomain.com

# Test dengan wget - seharusnya 403
wget --user-agent="wget" https://yourdomain.com

# Test dengan browser normal - seharusnya berhasil
curl https://yourdomain.com
```

### 6.2 Test SQL Injection
```bash
# Seharusnya diblokir (403)
curl "https://yourdomain.com/index.php?id=1' OR '1'='1"
```

### 6.3 Test rate limiting
```bash
# Test request cepat (seharusnya kena rate limit)
for i in {1..30}; do curl https://yourdomain.com; done
```

## Step 7: Monitoring dan Log

### 7.1 Monitor real-time log
```bash
# Monitor access log
sudo tail -f /var/www/yourdomain.com/logs/access.log

# Monitor error log
sudo tail -f /var/www/yourdomain.com/logs/error.log

# Filter hanya yang diblokir (403)
sudo tail -f /var/www/yourdomain.com/logs/access.log | grep "403"
```

### 7.2 Buat script monitoring sederhana
```bash
sudo nano /usr/local/bin/monitor-bot.sh
```

Isi dengan:
```bash
#!/bin/bash
echo "=== Bot Detection Report ==="
echo "Blocked User-Agents last hour:"
sudo grep "403" /var/www/yourdomain.com/logs/access.log | tail -100 | grep -E "(curl|wget|nmap|nikto)" | wc -l
echo ""
echo "Top 10 blocked IPs:"
sudo grep "403" /var/www/yourdomain.com/logs/access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
```

Jadikan executable:
```bash
sudo chmod +x /usr/local/bin/monitor-bot.sh
```

## Step 8: Setup Fail2ban (Opsional)

### 8.1 Install fail2ban
```bash
sudo apt install fail2ban -y
```

### 8.2 Buat filter untuk Nginx
```bash
sudo nano /etc/fail2ban/filter.d/nginx-bot.conf
```

Isi:
```ini
[Definition]
failregex = ^<HOST> -.*(curl|wget|nmap|nikto|burpsuite|sqlmap).*$
            ^<HOST> -.*"POST.*(union|select|drop).*".*$
ignoreregex =
```

### 8.3 Konfigurasi jail
```bash
sudo nano /etc/fail2ban/jail.local
```

Isi:
```ini
[nginx-bot]
enabled = true
port = http,https
filter = nginx-bot
logpath = /var/www/yourdomain.com/logs/access.log
maxretry = 3
bantime = 3600
findtime = 600
```

### 8.4 Restart fail2ban
```bash
sudo systemctl restart fail2ban
sudo fail2ban-client status nginx-bot
```

## Step 9: Verifikasi Final

### 9.1 Cek semua berjalan normal
```bash
# Cek status Nginx
sudo systemctl status nginx

# Cek listening ports
sudo netstat -tulpn | grep nginx

# Test dengan browser
# Buka https://yourdomain.com di browser
```

### 9.2 Cek log untuk konfirmasi
```bash
# Cek log error
sudo tail -20 /var/www/yourdomain.com/logs/error.log

# Seharusnya tidak ada error
```

## Troubleshooting Umum

### Jika website tidak bisa diakses:
```bash
# Cek konfigurasi
sudo nginx -t

# Cek port 80 dan 443
sudo lsof -i :80
sudo lsof -i :443

# Cek firewall
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Jika rate limit terlalu ketat:
Edit file konfigurasi, ubah:
```nginx
limit_req zone=api_limit burst=50 nodelay;  # Tambah burst
limit_req zone=login_limit rate=10r/m;      # Rate lebih tinggi
```

### Jika User-Agent normal terblokir:
Tambahkan pengecualian di map block:
```nginx
map $http_user_agent $blocked_ua {
    default 0;
    ~*(Googlebot|bingbot|DuckDuckBot) 0;  # Izinkan bot baik
    ~*(curl|wget|nmap) 1;  # Block bot jahat
}
```