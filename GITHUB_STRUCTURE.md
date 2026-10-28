# 📦 GitHub Structure & Setup

**Repository:** https://github.com/Muhammad-Ikhwan-Fathulloh/Network-Security-Course-Bank

---

## 📁 Folder Organization

```
Network-Security-Course-Bank/
│
├── Labs/
│   ├── docker-compose-p4.yml      ✅ Wireless lab config
│   ├── docker-compose-p5.yml      ✅ L3 lab config
│   ├── docker-compose-p6.yml      ✅ L4 lab config
│   ├── docker-compose-p7.yml      ✅ DNS lab config
│   ├── README.md                  ✅ Comprehensive guide
│   └── QUICK_REFERENCE.md         ✅ Commands cheat sheet
│
├── Pertemuan0.md ... Pertemuan3/  (Original materials)
│
├── Pertemuan4/                    ✅ Updated structure
│   ├── README.md
│   ├── INDEX.md
│   ├── captures/
│   ├── wordlists/
│   ├── configs/
│   └── scripts/
│
├── Pertemuan5/                    ✅ Updated structure
│   ├── README.md
│   ├── INDEX.md
│   ├── scripts/
│   │   └── smurf_attack.py
│   ├── captures/
│   └── configs/
│
├── Pertemuan6/                    ✅ Updated structure
│   ├── README.md
│   ├── INDEX.md
│   ├── captures/
│   ├── scripts/
│   └── configs/
│
├── Pertemuan7/                    ✅ Updated structure
│   ├── README.md
│   ├── INDEX.md
│   ├── scripts/
│   │   └── dns_spoof.py
│   ├── captures/
│   └── configs/
│
└── (Other materials - ARP, SetupVPS, etc)
```

---

## 🚀 How to Use

### 1. Clone Repository
```bash
git clone https://github.com/Muhammad-Ikhwan-Fathulloh/Network-Security-Course-Bank.git
cd Network-Security-Course-Bank
```

### 2. Choose Your Lab (Pertemuan 4-7)

Each Pertemuan has centralized docker-compose config in **Labs/** folder.

### 3. Start Lab
```bash
# Go to Labs folder (centralized docker configs)
cd Labs

# Start Pertemuan 5 (example)
docker-compose -f docker-compose-p5.yml up -d

# Access container
docker-compose -f docker-compose-p5.yml exec attacker-l3 bash
```

### 4. Follow Guide
- Read theory from `Pertemuan5.md`
- Follow hands-on from `Pertemuan5/README.md`
- Reference commands in `Labs/QUICK_REFERENCE.md`

---

## 🐳 Docker-Compose Files Location

All docker-compose files are **centralized in Labs/ folder**:
- `docker-compose-p4.yml` - Wireless Security
- `docker-compose-p5.yml` - L3 Attacks
- `docker-compose-p6.yml` - L4 Attacks
- `docker-compose-p7.yml` - DNS Attacks

**Each Pertemuan folder NO LONGER has docker-compose.yml**

---

## 📚 Documentation Structure

**Theory & Hands-on:**
- `Pertemuan4.md` - Full Pertemuan 4 guide
- `Pertemuan5.md` - Full Pertemuan 5 guide
- `Pertemuan6.md` - Full Pertemuan 6 guide
- `Pertemuan7.md` - Full Pertemuan 7 guide

**Lab Guides (in Pertemuan folders):**
- `Pertemuan4/README.md` - Quick start
- `Pertemuan4/INDEX.md` - Lab overview
(Same for P5, P6, P7)

**Centralized Resources (in Labs folder):**
- `Labs/README.md` - Comprehensive guide
- `Labs/QUICK_REFERENCE.md` - Commands cheat sheet

---

## ✨ Key Changes

✅ **Centralized Docker configs** - All in Labs/ folder only
✅ **Removed individual docker-compose.yml** from Pertemuan folders
✅ **No Burp Suite** - Simplified, focused on essential tools
✅ **Updated all README.md** - Points to GitHub repo
✅ **Cleaner structure** - Easy to navigate and understand

---

## 🎯 Getting Started

1. **Clone repo:**
   ```bash
   git clone https://github.com/Muhammad-Ikhwan-Fathulloh/Network-Security-Course-Bank.git
   ```

2. **Choose lab (e.g., Pertemuan 5):**
   ```bash
   cd Labs
   docker-compose -f docker-compose-p5.yml up -d
   ```

3. **Read guide:**
   ```bash
   cat ../Pertemuan5/README.md
   ```

4. **Follow hands-on:**
   - Open `../Pertemuan5.md`
   - Follow sections 1-7

---

## 📞 Documentation Links

- **Main repo:** https://github.com/Muhammad-Ikhwan-Fathulloh/Network-Security-Course-Bank
- **Start here:** Read `Pertemuan4/README.md`, `Pertemuan5/README.md`, etc.
- **Commands:** See `Labs/QUICK_REFERENCE.md`
- **Full guide:** See `Labs/README.md`

---

**All set! Ready for students to use!** ✅
