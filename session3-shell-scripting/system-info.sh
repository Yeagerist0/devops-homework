#!/usr/bin/env bash
set -euo pipefail

read -r -p "Enter an output directory [system-info-output]: " output_dir
output_dir="${output_dir:-system-info-output}"
mkdir -p "$output_dir"
process_file="$output_dir/processes.txt"
date_now="$(date)"
host_name="$(hostname)"
user_name="${USER:-$(id -un)}"

echo "Date: $date_now"
echo "Hostname: $host_name"
echo "Username: $user_name"
echo "Disk usage:"
df -h
echo "Running processes:"
ps aux
ps aux > "$process_file"
touch "$output_dir/README.txt"
echo "Process list saved to $process_file"
