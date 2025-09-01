#!/bin/bash

# Usage: ./auto-swap.sh
# to check the memory and swap usage and create a swap file if necessary

# Usage: ./auto-swap.sh -d
# to display the full details of memory and swap usage

if [ "$1" == "-d" ]; then
    echo "Total RAM: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Total Swap: $(free -h | awk '/^Swap:/ {print $2}')"
    echo "Total used memory: $(free -h | awk '/^Mem:/ {print $3}')"
    echo "Total used swap: $(free -h | awk '/^Swap:/ {print $3}')"
    echo "Remaining memory: $(free -h | awk '/^Mem:/ {print $4}')"
    echo "Remaining swap: $(free -h | awk '/^Swap:/ {print $4}')"
    exit 0
fi

remaining_memory_gb=$(awk '/^Mem:/ {print $4}' <(free --bytes))
remaining_swap_gb=$(awk '/^Swap:/ {print $4}' <(free --bytes))

# if remaining memory + remaining swap is less than 1GB, create a swap file
if [ $((remaining_memory_gb + remaining_swap_gb)) -lt 1000000000 ]; then
    echo "Creating swap file..."
    ./swap.sh
fi
if [ $((remaining_memory_gb + remaining_swap_gb)) -gt 6000000000 ]; then
    echo "Deleting swap file..."
    ./swap.sh -d
fi
