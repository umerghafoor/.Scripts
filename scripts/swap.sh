#!/bin/bash

# Usage: ./swap.sh [directory] [size]
# Examples:
#   ./swap.sh /mnt 4G      -> Create 4G swap file in /mnt
#   ./swap.sh 4G           -> Create 4G swap file in home directory
#   ./swap.sh              -> Create default 4G swap in home directory
#   ./swap.sh -d           -> Delete last active swap file
#   ./swap.sh -m           -> Move swap to RAM if RAM > 2GB
#   ./swap.sh -c           -> Clean unused swap files from disk and fstab
#   ./swap.sh -h           -> Show this help message

SWAPDIR="$HOME"
SWAPNAME=".swapfile"
SWAPSIZE="4G"

# Help
if [ "$1" == "-h" ]; then
  echo "Usage: ./swap.sh [directory] [size]"
  echo "Examples:"
  echo "  ./swap.sh /mnt 4G      -> Create 4G swap file in /mnt"
  echo "  ./swap.sh 4G           -> Create 4G swap file in home directory"
  echo "  ./swap.sh              -> Create default 4G swap in home directory"
  echo "  ./swap.sh -d           -> Delete last active swap file"
  echo "  ./swap.sh -m           -> Move swap to RAM if RAM > 2GB"
  echo "  ./swap.sh -c           -> Clean unused swap files from disk and fstab"
  echo "  ./swap.sh -h           -> Show this help message"
  exit 0
fi

# Delete last used swap
if [ "$1" == "-d" ]; then
  SWAPFILE=$(swapon --show | tail -n 1 | awk '{print $1}')
  if [ ! -z "$SWAPFILE" ]; then
    sudo swapoff "$SWAPFILE"
    sudo sed -i "/$SWAPFILE/d" /etc/fstab
    sudo rm -f "$SWAPFILE"
    echo "Deleted swap file: $SWAPFILE"
  else
    echo "No swap file found!"
  fi
  exit 0
fi

# Move swap to RAM
if [ "$1" == "-m" ]; then
  if [ $(free -m | grep Mem | awk '{print $2}') -gt 2000 ]; then
    echo "Main memory is more than 2GB. Moving swap to main memory..."
    sudo swapoff -a
    exit 0
  else
    echo "Main memory is less than 2GB. Swap file will be created."
  fi
fi

# Clean unused swap files
if [ "$1" == "-c" ]; then
  echo "Cleaning unused swap files..."
  ACTIVE_SWAPS=$(swapon --noheadings --show=NAME)
  FIND_DIRS=("/" "/mnt" "$HOME")

  for dir in "${FIND_DIRS[@]}"; do
    sudo find "$dir" -maxdepth 1 -type f -name ".swapfile*" 2>/dev/null | while read -r file; do
      if ! echo "$ACTIVE_SWAPS" | grep -q "$file"; then
        echo "Removing unused swap: $file"
        sudo swapoff "$file" 2>/dev/null
        sudo rm -f "$file"
        sudo sed -i "\|$file|d" /etc/fstab
      fi
    done
  done
  echo "Done."
  exit 0
fi

# If only one argument and it's a size (like "4G")
if [[ "$1" =~ ^[0-9]+[KMG]$ ]] && [ -z "$2" ]; then
  SWAPSIZE="$1"
  SWAPDIR="$HOME"
else
  if [ ! -z "$1" ]; then
    SWAPDIR="$1"
  fi
  if [ ! -z "$2" ]; then
    SWAPSIZE="$2"
  fi
fi

# Create unique swap file
SWAPFILE="$SWAPDIR/$SWAPNAME"
COUNT=1
while [ -f "$SWAPFILE" ]; do
  SWAPFILE="$SWAPDIR/$SWAPNAME$COUNT"
  ((COUNT++))
done

# Create swap
sudo truncate -s 0 "$SWAPFILE"
sudo chattr +C "$SWAPFILE" 2>/dev/null
sudo fallocate -l "$SWAPSIZE" "$SWAPFILE"
sudo chmod 600 "$SWAPFILE"
sudo mkswap "$SWAPFILE"
sudo swapon "$SWAPFILE"
echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
swapon --show
