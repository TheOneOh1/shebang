#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
CYAN='\033[0;36m'

print_header() {
    echo -e "\n${BLUE}  _________.__                   _________              __               ${NC}"
    echo -e "${BLUE} /   _____/|__|______           /   _____/ ____________/  |_  ___________  ${NC}"
    echo -e "${BLUE} \_____  \ |  \_  __ \  ______  \_____  \ /  _ \_  __ \   __\/ __ \_  __ \ ${NC}"
    echo -e "${BLUE} /        \|  ||  | \/ /_____/  /        (  <_> )  | \/|  | \  ___/|  | \/ ${NC}"
    echo -e "${BLUE}/_______  /|__||__|            /_______  /\____/|__|   |__|  \___  >__|    ${NC}"
    echo -e "${BLUE}        \/                             \/                        \/        ${NC}\n"
}

# Function to move files into directories based on their extensions
move() {
    for file in *; do
        # Skip if current item is a directory
        [ -d "$file" ] && continue

        extension="${file##*.}"
        mkdir -p "$extension"
        mv "$file" "$extension"
        echo -e "${CYAN}Moving:${NC} $file ${CYAN}→${NC} $extension/"
    done
}

copy() {
    for file in *; do
        [ -d "$file" ] && continue

        extension="${file##*.}"
        mkdir -p "$extension"
        cp "$file" "$extension"
        echo -e "${CYAN}Copying:${NC} $file ${CYAN}→${NC} $extension/"
    done
}

# Main script execution
print_header

# Get user input
#echo -e "${YELLOW}Choose an option:${NC}"
echo -e "${CYAN}c${NC} - Copy files to sorted folders"
echo -e "${CYAN}m${NC} - Move files to sorted folders"
read -p "Enter your choice (c/m): " srt
echo

# Process based on user choice
case "$srt" in
    "c")
        copy
        echo -e "\n${GREEN}✓ Files have been COPIED successfully${NC}"
        ;;
    "m")
        move
        echo -e "\n${GREEN}✓ Files have been MOVED successfully${NC}"
        ;;
    *)
        echo -e "\n${RED}⚠ Invalid Input${NC}"
        echo -e "${YELLOW}Try '${CYAN}c${NC}${YELLOW}' to COPY Files | Try '${CYAN}m${NC}${YELLOW}' to MOVE Files${NC}"
        ;;
esac

echo -e "\n${CYAN}-------------------------------------------------${NC}\n"
