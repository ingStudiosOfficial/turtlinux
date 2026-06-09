#!/bin/bash

# TurtLinux ISO Maker
# by https://anw.is-a.dev

GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m' # no color (reset)

mkdir -p ./iso

echo -e "${LIGHT_GREEN}===================================${NC}"
echo -e "${LIGHT_GREEN}|${GREEN}      Turtlinux ISO Maker        ${LIGHT_GREEN}|${NC}"
echo -e "${LIGHT_GREEN}===================================${NC}"
echo ""
echo -e "${GREEN}Select the flavor you wish to build:${NC}"
echo "+-----------------\\ /----------------------------------------------------+"
echo "| FLAVOR           | URL                                                 |"
echo "+------------------+-----------------------------------------------------+"
echo "| 1 - Latest Rel.  | https://ghcr.io/ingStudiosOfficial/turtlinux:latest |"
echo "| 2 - Development  | https://ghcr.io/SubhrajitSain/turtlinux:latest      |"
echo "+-----------------/ \\----------------------------------------------------+"
echo ""
read -p "Enter selection [1-2]: " choice

case "$choice" in
    1)
        TARGET_IMAGE="ghcr.io/ingstudiosofficial/turtlinux:latest"
        ;;
    2)
        TARGET_IMAGE="ghcr.io/subhrajitsain/turtlinux:latest"
        ;;
    *)
        echo -e "${RED}Error: Invalid option chosen. Aborting build process.${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Selected reference target: ${LIGHT_GREEN}${TARGET_IMAGE}${NC}"
echo -e "${GREEN}Launching Podman, see below for output.${NC}"
echo -e "${LIGHT_GREEN}-----------------------------------------------${NC}"

if sudo podman run \
  --rm \
  -it \
  --privileged \
  -v ./iso:/iso \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type iso \
  "$TARGET_IMAGE"
then
    echo -e "${LIGHT_GREEN}-----------------------------------------------${NC}"
    echo -e "${GREEN}Cleaning up...${NC}"
    sudo podman system prune -a -f
    echo -e "${GREEN}Finished, check ./iso for your TurtLinux ISO.${NC}"
else
    echo -e "${LIGHT_GREEN}-----------------------------------------------${NC}"
    echo -e "${RED}Build failed, cache not cleaned.${NC}"
    echo "Run 'sudo podman system prune -a -f' to clean manually and freshen up."
fi
