#!/bin/bash
#
# UTS Network Security - Student Cleanup Script
# Jalankan ini SETELAH selesai mengerjakan semua tugas
# Usage: bash cleanup.sh
#

set -e

echo "=========================================="
echo "  UTS Network Security - Cleanup"
echo "=========================================="
echo ""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if Docker is running
if ! docker ps &> /dev/null; then
    echo -e "${RED}✗ Docker daemon tidak berjalan${NC}"
    exit 1
fi

echo -e "${BLUE}Cleaning up Docker resources...${NC}"
echo ""

# Step 1: Show current state
echo -e "${YELLOW}=== Current State ===${NC}"
echo "Containers running:"
docker ps --format "table {{.Names}}\t{{.Status}}" || echo "  (none)"

echo ""
echo "Networks (excluding default):"
docker network ls --format "table {{.Name}}\t{{.Driver}}" | grep -v "bridge\|host\|none" || echo "  (none)"

echo ""
echo "Volumes:"
docker volume ls --format "table {{.Name}}" | grep -v "local" || echo "  (none - standard only)"

echo ""

# Step 2: Stop all containers
echo -e "${YELLOW}=== Stopping Containers ===${NC}"
if [ "$(docker ps -q)" ]; then
    echo "Stopping running containers..."
    docker stop $(docker ps -q)
    echo -e "${GREEN}✓ Containers stopped${NC}"
else
    echo "  (no running containers)"
fi

# Step 3: Remove all containers
echo ""
echo -e "${YELLOW}=== Removing Containers ===${NC}"
if [ "$(docker ps -a -q)" ]; then
    echo "Removing all containers..."
    docker rm -f $(docker ps -a -q)
    echo -e "${GREEN}✓ All containers removed${NC}"
else
    echo "  (no containers to remove)"
fi

# Step 4: Remove UTS-specific networks
echo ""
echo -e "${YELLOW}=== Removing Networks ===${NC}"
networks_to_remove=$(docker network ls --format "{{.Name}}" | grep -E "lab|test|arp|wireless|k[0-9]" || true)
if [ ! -z "$networks_to_remove" ]; then
    echo "Removing UTS networks:"
    echo "$networks_to_remove" | while read net; do
        docker network rm "$net" 2>/dev/null && echo "  ✓ $net"
    done
    echo -e "${GREEN}✓ Networks removed${NC}"
else
    echo "  (no UTS networks to remove)"
fi

# Step 5: Remove UTS-specific volumes
echo ""
echo -e "${YELLOW}=== Removing Volumes ===${NC}"
volumes_to_remove=$(docker volume ls --format "{{.Name}}" | grep -E "vol-k|data-uts|capture" || true)
if [ ! -z "$volumes_to_remove" ]; then
    echo "Removing UTS volumes:"
    echo "$volumes_to_remove" | while read vol; do
        docker volume rm "$vol" 2>/dev/null && echo "  ✓ $vol"
    done
    echo -e "${GREEN}✓ Volumes removed${NC}"
else
    echo "  (no UTS volumes to remove)"
fi

# Step 6: Prune system (optional - be careful!)
echo ""
echo -e "${YELLOW}=== System Cleanup ===${NC}"
read -p "Prune unused Docker resources? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker system prune -f
    echo -e "${GREEN}✓ System pruned${NC}"
else
    echo "  (skipped)"
fi

# Step 7: Final verification
echo ""
echo -e "${YELLOW}=== Final Verification ===${NC}"
echo "Remaining containers:"
docker ps -a | wc -l | xargs echo "  Total:"
if [ "$(docker ps -a -q)" ]; then
    echo -e "${RED}  ⚠ Warning: Still have containers!${NC}"
    docker ps -a --format "table {{.Names}}\t{{.Status}}"
else
    echo -e "${GREEN}  ✓ Clean (no containers)${NC}"
fi

echo ""
echo "Remaining networks (excluding default):"
docker network ls --format "table {{.Name}}\t{{.Driver}}" | grep -v "bridge\|host\|none" | wc -l | xargs echo "  Total:"
if [ "$(docker network ls --format '{{.Name}}' | grep -v 'bridge\|host\|none')" ]; then
    echo -e "${RED}  ⚠ Warning: Still have custom networks!${NC}"
else
    echo -e "${GREEN}  ✓ Clean (only default networks)${NC}"
fi

echo ""
echo "Remaining volumes:"
docker volume ls --format "table {{.Name}}" | grep -v "local" | wc -l | xargs echo "  Total:"
if [ "$(docker volume ls --format '{{.Name}}' | grep -v 'local')" ]; then
    echo -e "${RED}  ⚠ Warning: Still have custom volumes!${NC}"
else
    echo -e "${GREEN}  ✓ Clean (only local volumes)${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✓ Cleanup Complete!${NC}"
echo ""
echo "Checklist untuk kumpulkan:"
echo "  [ ] Semua 7 Tugas sudah dikerjakan"
echo "  [ ] Output ada di jawaban.md"
echo "  [ ] Semua container sudah dihapus"
echo "  [ ] Semua network sudah dihapus"
echo "  [ ] Semua volume sudah dihapus"
echo ""
echo "Siap untuk kumpulkan jawaban.md ke penguji!"
echo "=========================================="

