#!/bin/bash
#
# UTS Network Security Lab - Automated Setup Script
# Script ini membantu setup semua image dan base containers sebelum ujian
# Gunakan: bash setup.sh [build|verify|cleanup]
#

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_DIR="$SCRIPT_DIR/images"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  UTS Network Security Lab Setup${NC}"
echo -e "${BLUE}========================================${NC}"

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker tidak terinstall${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null || ! docker compose version &> /dev/null; then
    echo -e "${RED}✗ Docker Compose tidak terinstall${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker terinstall${NC}"
echo -e "  Docker: $(docker --version)"
echo -e "  Compose: $(docker compose version --short)"
echo ""

# Function to build custom images
build_images() {
    echo -e "${YELLOW}=== Membangun Custom Images ===${NC}"

    images=("uts-openssl" "uts-kali-tools" "uts-dnsmasq")

    for img in "${images[@]}"; do
        echo ""
        echo -e "${BLUE}Building: $img${NC}"

        if docker build -t "$img" "$IMAGES_DIR/$img"; then
            echo -e "${GREEN}✓ $img berhasil dibangun${NC}"
        else
            echo -e "${RED}✗ $img gagal dibangun${NC}"
            exit 1
        fi
    done
}

# Function to pull base images
pull_images() {
    echo ""
    echo -e "${YELLOW}=== Mengunduh Base Images ===${NC}"

    base_images=(
        "alpine:3.20"
        "nginx:alpine"
        "vulnerables/web-dvwa"
        "kalilinux/kali-rolling"
    )

    for img in "${base_images[@]}"; do
        echo ""
        echo -e "${BLUE}Pulling: $img${NC}"

        if docker pull "$img"; then
            echo -e "${GREEN}✓ $img berhasil diunduh${NC}"
        else
            echo -e "${RED}✗ $img gagal diunduh${NC}"
            exit 1
        fi
    done
}

# Function to verify images exist
verify_images() {
    echo ""
    echo -e "${YELLOW}=== Verifikasi Semua Images ===${NC}"
    echo ""

    required_images=(
        "uts-openssl"
        "uts-kali-tools"
        "uts-dnsmasq"
        "alpine"
        "nginx"
        "vulnerables/web-dvwa"
        "kalilinux/kali-rolling"
    )

    all_present=true

    for img in "${required_images[@]}"; do
        if docker image inspect "$img" &> /dev/null; then
            size=$(docker image inspect "$img" --format='{{.Size}}')
            size_mb=$((size / 1024 / 1024))
            echo -e "${GREEN}✓${NC} $img (${size_mb}MB)"
        else
            echo -e "${RED}✗${NC} $img TIDAK ADA"
            all_present=false
        fi
    done

    echo ""
    if [ "$all_present" = true ]; then
        echo -e "${GREEN}✓ Semua images ready${NC}"
        return 0
    else
        echo -e "${RED}✗ Ada images yang hilang${NC}"
        return 1
    fi
}

# Function to test basic functionality
test_functionality() {
    echo ""
    echo -e "${YELLOW}=== Testing Basic Functionality ===${NC}"

    # Test A1: Port mapping
    echo ""
    echo -e "${BLUE}Test A1: Port Mapping${NC}"
    docker run -d --name test-port-8888 -p 8888:80 nginx:alpine > /dev/null 2>&1
    sleep 2
    if curl -s http://localhost:8888 | grep -q "nginx"; then
        echo -e "${GREEN}✓ Port mapping works${NC}"
    else
        echo -e "${RED}✗ Port mapping failed${NC}"
    fi
    docker rm -f test-port-8888 > /dev/null 2>&1

    # Test A5: Network bridge
    echo ""
    echo -e "${BLUE}Test A5: Bridge Network${NC}"
    docker network create test-bridge 2>/dev/null || true
    docker run -d --name test-net-a --network test-bridge alpine sleep 30 > /dev/null 2>&1
    docker run -d --name test-net-b --network test-bridge alpine sleep 30 > /dev/null 2>&1
    sleep 1
    if docker exec test-net-a ping -c 1 test-net-b &> /dev/null; then
        echo -e "${GREEN}✓ Bridge network works${NC}"
    else
        echo -e "${RED}✗ Bridge network failed${NC}"
    fi
    docker rm -f test-net-a test-net-b > /dev/null 2>&1
    docker network rm test-bridge 2>/dev/null || true

    # Test B1: Docker Compose + Internal network
    echo ""
    echo -e "${BLUE}Test B1: Docker Compose & Internal Network${NC}"
    cd "$SCRIPT_DIR/b/b1-compose"
    if docker compose up -d > /dev/null 2>&1; then
        sleep 2
        if docker compose exec attacker wget -qO- http://target 2>/dev/null | grep -q "nginx"; then
            echo -e "${GREEN}✓ Internal network + compose works${NC}"
        else
            echo -e "${RED}✗ Compose exec failed${NC}"
        fi
        docker compose down -v > /dev/null 2>&1
    else
        echo -e "${RED}✗ Compose up failed${NC}"
    fi
    cd "$SCRIPT_DIR"

    echo ""
    echo -e "${GREEN}✓ Semua test selesai${NC}"
}

# Function to clean up
cleanup() {
    echo ""
    echo -e "${YELLOW}=== Cleanup ===${NC}"

    echo "Menghapus test containers..."
    docker rm -f test-* 2>/dev/null || true

    echo "Menghapus test networks..."
    docker network rm test-* 2>/dev/null || true

    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Function to show status
show_status() {
    echo ""
    echo -e "${YELLOW}=== Status Sistem ===${NC}"

    echo ""
    echo "Images yang terinstall:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "uts-|alpine|nginx|dvwa|kali" || echo "  (none)"

    echo ""
    echo "Disk usage Docker:"
    docker system df

    echo ""
    echo "Docker daemon status:"
    if systemctl is-active --quiet docker 2>/dev/null; then
        echo -e "${GREEN}✓ Docker daemon running${NC}"
    else
        echo -e "${RED}✗ Docker daemon not running${NC}"
    fi
}

# Main menu
case "${1:-build}" in
    build)
        build_images
        pull_images
        verify_images
        test_functionality
        cleanup
        show_status
        echo ""
        echo -e "${GREEN}=== Setup berhasil! ===${NC}"
        echo "Siap untuk ujian."
        echo ""
        ;;
    verify)
        verify_images
        show_status
        ;;
    test)
        test_functionality
        cleanup
        ;;
    cleanup)
        cleanup
        show_status
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: $0 [build|verify|test|cleanup|status]"
        echo ""
        echo "Commands:"
        echo "  build     - Build custom images, pull base images, verify, dan test (DEFAULT)"
        echo "  verify    - Hanya verifikasi images ada"
        echo "  test      - Hanya test functionality"
        echo "  cleanup   - Hapus test containers dan networks"
        echo "  status    - Tampilkan status sistem Docker"
        echo ""
        echo "Examples:"
        echo "  bash setup.sh           # Full setup"
        echo "  bash setup.sh verify    # Check if images exist"
        echo "  bash setup.sh status    # Show system status"
        exit 1
        ;;
esac

