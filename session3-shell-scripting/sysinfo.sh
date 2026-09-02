#!/bin/bash

read -p "Enter your name: " user_name
read -p "Enter a folder name to create: " folder_name

current_date=$(date)
current_host=$(hostname)
current_user=$(whoami)

echo "Hello, $user_name"
echo "Date: $current_date"
echo "Hostname: $current_host"
echo "Username: $current_user"

echo "Disk Usage:"
df -h

echo "Running Processes:"
ps aux

mkdir -p "$folder_name"
echo "Directory $folder_name created"

touch "$folder_name/processes.txt"
echo "File processes.txt created"

ps aux > "$folder_name/processes.txt"
echo "Running processes saved in $folder_name/processes.txt"
