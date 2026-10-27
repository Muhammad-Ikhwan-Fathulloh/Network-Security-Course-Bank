# 🚀 START HERE - Network Security Course (v2.0)

Welcome to the **Enhanced Network Security Course** with Docker integration and improved visualizations!

**Last Updated:** 2025-10-27  
**Status:** ✅ Ready to use

---

## 📚 What Has Changed?

Your course now has:

✅ **Docker Labs** - Zero-configuration lab setup for Pertemuan 4-7  
✅ **Better Visualizations** - 12+ diagrams untuk teori yang lebih mudah dipahami  
✅ **Comprehensive Guides** - 5000+ lines dokumentasi baru  
✅ **Quick Reference** - Cheat sheet untuk semua commands  

**Bottom Line:** Setup lab dalam 30 detik, bukan 30 menit!

---

## 🎯 3 Steps to Get Started

### Step 1️⃣ : Install Docker (5 minutes)

**Windows/Mac:**
1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Install dan restart
3. Verify: `docker --version`

**Linux:**
```bash
curl -fsSL https://get.docker.com | sh
docker --version
```

### Step 2️⃣ : Choose Your First Lab

Pick one of these (in order):
- **Pertemuan 5** - L3 Security (easiest, good introduction)
- **Pertemuan 4** - Wireless Security
- **Pertemuan 6** - L4 Security (TCP/UDP)
- **Pertemuan 7** - DNS Security

### Step 3️⃣ : Run Your First Lab

```bash
# Go to course folder
cd ~/Network-Security-Course-Bank/Labs

# Create lab directory
mkdir p5-l3 && cd p5-l3

# Copy docker-compose file
cp ../docker-compose-p5.yml .

# Start lab
docker-compose up -d

# Verify (should show 4 containers)
docker-compose ps

# Done! ✅
```

**That's it! Your lab is running.**

---

## 📖 What to Read Next

### For First Time Users
1. **Read:** `Labs/README.md` (Prerequisites section) - 10 minutes
2. **Read:** `Labs/QUICK_REFERENCE.md` (Quick Start section) - 5 minutes
3. **Run:** First lab following steps above - 5 minutes
4. **Read:** Relevant Pertemuan file (section 3 untuk Docker setup) - 15 minutes
5. **Practice:** Hands-on dari Pertemuan file (section 4+) - 30+ minutes

### For Experienced Users
- Jump straight to `Labs/docker-compose-pX.yml`
- Reference `Labs/QUICK_REFERENCE.md` untuk commands
- Follow hands-on sections di Pertemuan files

---

## 📁 File Structure

```
Network-Security-Course-Bank/
├── START_HERE.md ← You are here
├── RELEASE_NOTES.md ← What changed
├── IMPROVEMENTS_SUMMARY.md ← Detailed improvements
├── SETUP_CHECKLIST.md ← Verification checklist
│
├── Pertemuan4.md ✅ Updated (Docker + visualizations)
├── Pertemuan5.md ✅ Updated (Docker + visualizations)
├── Pertemuan6.md ✅ Updated (Docker + visualizations)
├── Pertemuan7.md ✅ Updated (Docker + visualizations)
├── Pertemuan8-16.md (Original content, can upgrade later)
│
└── Labs/
    ├── README.md ← Main guide (2000+ lines)
    ├── QUICK_REFERENCE.md ← Commands cheat sheet
    ├── docker-compose-p4.yml ✅ Wireless
    ├── docker-compose-p5.yml ✅ L3 Security
    ├── docker-compose-p6.yml ✅ L4 Security
    ├── docker-compose-p7.yml ✅ DNS Security
    └── (folder untuk lab captures di sini)
```

---

## 🎓 Learning Path

### Week 1: Introduction
**Focus:** Docker basics + first lab

- Day 1-2: Learn Docker (read README prerequisites)
- Day 3-5: Run Pertemuan 5 lab completely
- Goal: Comfortable dengan docker-compose commands

### Week 2: All Labs
**Focus:** Hands-on dengan semua lab

- Day 1: P4 (Wireless)
- Day 2: P5 (L3)
- Day 3: P6 (L4)
- Day 4: P7 (DNS)
- Day 5: Advanced scenarios / Repeat interesting labs

### Week 3+: Deep Dive
**Focus:** Modify dan customize labs

- Modify docker-compose untuk complex scenarios
- Write custom attack scripts
- Combine multiple labs
- Document your findings

---

## ❓ Frequently Asked Questions

**Q: Apakah Docker wajib digunakan?**  
A: Tidak! Original hands-on dengan fisik/VM masih bisa dijalankan. Docker hanya lebih convenient.

**Q: Bagaimana dengan Pertemuan 8-16?**  
A: Masih menggunakan original setup. Docker integration untuk P8-16 akan ditambah di fase berikutnya.

**Q: Apakah lab network akan affect production network?**  
A: Tidak! Docker labs fully isolated. Tidak akan mengganggu host network.

**Q: Berapa RAM yang dibutuhkan?**  
A: Minimum 4 GB, recommended 8 GB. Setiap lab ~200-500 MB.

**Q: Bisa jalankan multiple labs sekaligus?**  
A: Ya! Selama port tidak conflict. Recommend jalankan satu per satu untuk fokus.

**Lihat lebih banyak FAQ di `Labs/README.md`**

---

## 🔧 Common Tasks

### Access a Container
```bash
cd Labs/p5-l3
docker-compose exec attacker-l3 bash
```

### Monitor What's Happening
```bash
# Terminal 1: See all containers
docker-compose ps

# Terminal 2: Watch container logs
docker-compose logs -f

# Terminal 3: Monitor network traffic
docker-compose exec monitor-l3 tcpdump -i eth0
```

### Cleanup Lab
```bash
# Stop containers (data preserved)
docker-compose down

# Stop AND delete volumes
docker-compose down -v
```

### Get Help
```bash
# Check quick commands
cat Labs/QUICK_REFERENCE.md

# Check main guide
cat Labs/README.md | less

# Check logs for errors
docker-compose logs <service-name>
```

---

## 🎯 What Each Pertemuan Teaches

| Pertemuan | Topic | Docker | Main Skills |
|-----------|-------|--------|------------|
| **4** | Wireless Security | ✅ | WiFi cracking, monitor mode |
| **5** | L3 Security | ✅ | ICMP attacks, spoofing, DHCP |
| **6** | L4 Security | ✅ | SYN flood, TCP hijacking, UDP |
| **7** | DNS Security | ✅ | DNS poisoning, exfiltration |
| 8-16 | Advanced Topics | ❓ | Various (coming soon) |

---

## ✨ Key Features

### 🐳 Docker Magic
- **Fast** - Start lab dalam 30 seconds
- **Isolated** - Lab network completely separate
- **Reproducible** - Exact same setup everywhere
- **Easy** - No complex networking setup needed

### 📊 Better Learning
- **Visual Diagrams** - 12+ flowcharts dan architecture diagrams
- **Step-by-Step** - Detailed instructions untuk setiap lab
- **Real Tools** - Semua Linux tools work normally
- **Monitoring** - tcpdump, wireshark, netstat semuanya berjalan

### 📚 Complete Documentation
- **Quick Start** - Get running dalam 5 menit
- **Detailed Guides** - Deep dives per lab
- **Troubleshooting** - Solutions untuk common issues
- **Cheat Sheets** - Quick reference untuk commands

---

## ⚡ Quick Commands Reference

```bash
# Start lab
docker-compose up -d

# List containers
docker-compose ps

# Access container
docker-compose exec <service> bash

# View logs
docker-compose logs <service>

# Monitor stats
docker stats

# Stop lab
docker-compose down

# Clean everything
docker-compose down -v
```

**Full cheat sheet:** `Labs/QUICK_REFERENCE.md`

---

## 📞 Need Help?

### Debugging Checklist
1. [ ] `docker-compose ps` - containers running?
2. [ ] `docker-compose logs` - any error messages?
3. [ ] `docker network inspect` - network OK?
4. [ ] Check `Labs/README.md` troubleshooting section
5. [ ] Check `SETUP_CHECKLIST.md` untuk verification

### Resources
- **Main Guide:** `Labs/README.md` (2000+ lines)
- **Quick Ref:** `Labs/QUICK_REFERENCE.md` (commands)
- **Improvements:** `IMPROVEMENTS_SUMMARY.md` (details)
- **Verification:** `SETUP_CHECKLIST.md` (checklist)

---

## 🎉 Ready?

```bash
# Copy this command dan jalankan sekarang:

cd ~/Network-Security-Course-Bank/Labs && \
mkdir p5-l3 && cd p5-l3 && \
cp ../docker-compose-p5.yml . && \
docker-compose up -d && \
echo "✅ Lab ready! Run: docker-compose ps"
```

**That's it! Lab Anda sudah running.** 🚀

---

## 📈 What's Next After First Lab?

1. ✅ **Complete** hands-on sections di Pertemuan file
2. ✅ **Analyze** PCAP captures di Wireshark
3. ✅ **Document** findings dan observations
4. ✅ **Cleanup** dengan `docker-compose down`
5. ✅ **Move on** ke next pertemuan

---

## 💡 Pro Tips

**Organize Your Labs:**
```bash
~/Labs/
├── p4-wireless/
├── p5-l3/
├── p6-l4/
└── p7-dns/
```

**Backup PCAP Files:**
```bash
mkdir -p ~/backup/pcaps
cp p5-l3/captures/* ~/backup/pcaps/
```

**Use Tmux for Multiple Terminals:**
```bash
tmux new-session -s lab
# Inside tmux, open multiple panes untuk monitoring
```

**Keep a Lab Journal:**
Document findings, observations, dan interesting discoveries.

---

## 📋 System Check

Before starting, verify:
```bash
docker --version          # Should be 20.10+
docker-compose --version  # Should be 1.29+
free -h | head -2        # At least 4 GB free RAM
df -h | grep /           # At least 2 GB free disk
```

---

## 🎓 Success Criteria

You'll know you're successful when:
- ✅ Containers start dengan `docker-compose up -d`
- ✅ Can access container dengan `docker-compose exec`
- ✅ Can see packets dengan tcpdump
- ✅ Can complete hands-on attack scenario
- ✅ Can analyze PCAP file hasil attack
- ✅ Can cleanup clean dengan `docker-compose down`

---

## 🚀 Let's Go!

1. **Install Docker** (jika belum)
2. **Read `Labs/README.md`** (prerequisites section)
3. **Run first lab** (follow Quick Start section)
4. **Follow hands-on** (di Pertemuan file)
5. **Have fun learning!** 🎉

---

**Questions?** Check the resources listed above.  
**Ready?** Start with `Labs/README.md`  
**Let's hack!** 🔐

---

## 📞 Support Path

1. **Quick questions** → Check `Labs/QUICK_REFERENCE.md`
2. **Setup help** → Check `Labs/README.md`
3. **Verification** → Check `SETUP_CHECKLIST.md`
4. **What changed?** → Check `IMPROVEMENTS_SUMMARY.md`
5. **Still stuck?** → Check `docker-compose logs`

---

**Version:** 2.0 with Docker Integration  
**Last Updated:** 2025-10-27  
**Status:** ✅ Production Ready

**Happy Learning! 🎓**
