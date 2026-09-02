# Session 3 - Shell Scripting Homework

## The script

[`sysinfo.sh`](sysinfo.sh)

```bash
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
```

### Every requirement from the homework, and where it is in the script

| requirement | line |
|---|---|
| prints the current date | `echo "Date: $current_date"` |
| prints the hostname | `echo "Hostname: $current_host"` |
| prints the username | `echo "Username: $current_user"` |
| prints the disk usage | `df -h` |
| prints the running processes | `ps aux` |
| uses variables | `user_name`, `folder_name`, `current_date`, `current_host`, `current_user` |
| takes user input with `read -p` | both `read -p` lines at the top |
| creates a directory with `mkdir` | `mkdir -p "$folder_name"` |
| creates a file with `touch` | `touch "$folder_name/processes.txt"` |
| stores processes in the file with `>` | `ps aux > "$folder_name/processes.txt"` |

---

## Running it

```
$ chmod +x sysinfo.sh
$ ./sysinfo.sh
Enter your name: Hitarth
Enter a folder name to create: sysinfo-output

Hello, Hitarth
Date: Wednesday 02 September 2026 10:38:02 AM IST
Hostname: SudoMatrix
Username: hitarth
Disk Usage:
Filesystem      Size  Used Avail Use% Mounted on
udev            7.4G     0  7.4G   0% /dev
tmpfs           1.5G  3.1M  1.5G   1% /run
/dev/nvme0n1p8  233G  199G   22G  91% /
tmpfs           7.5G   32M  7.5G   1% /dev/shm
efivarfs        128K   56K   68K  45% /sys/firmware/efi/efivars
/dev/nvme0n1p1  511M   40M  472M   8% /boot/efi
...

Running Processes:
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.1  27436 17152 ?        Ss   09:59   0:01 /sbin/init splash
root           2  0.0  0.0      0     0 ?        S    09:59   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        S    09:59   0:00 [pool_workqueue_release]
...
hitarth    53055  0.0  0.0   7228  3748 ?        S    10:38   0:00 /bin/bash ./sysinfo.sh
hitarth    53060  0.0  0.0  10756  5424 ?        R    10:38   0:00 ps aux

Directory sysinfo-output created
File processes.txt created
Running processes saved in sysinfo-output/processes.txt
```

## The file it produced

```
$ ls -l sysinfo-output
total 64
-rw-rw-r-- 1 hitarth hitarth 62540 Sep  2 10:38 processes.txt

$ wc -l sysinfo-output/processes.txt
489 sysinfo-output/processes.txt

$ head -4 sysinfo-output/processes.txt
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.1  27436 17152 ?        Ss   09:59   0:01 /sbin/init splash
root           2  0.0  0.0      0     0 ?        S    09:59   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        S    09:59   0:00 [pool_workqueue_release]
```

489 processes captured into the file by the `>` redirect.

---

## Notes on what I learned

- `read -p "prompt: " var` prints the prompt and reads into the variable in one go, no separate `echo` needed.
- `var=$(command)` is command substitution - it runs the command and puts the *output* into the variable. Note there are no spaces around the `=`, bash treats `var = value` as running a program called `var`.
- Variables are expanded inside double quotes but not single quotes: `"$folder_name"` becomes the value, `'$folder_name'` stays literal.
- I quoted `"$folder_name"` everywhere so a folder name with a space still works as one argument.
- `>` overwrites the file, `>>` appends. `ps aux > file` creates the file even if `touch` hadn't already, but the homework asked for `touch` so both are there.
- `mkdir -p` won't error if the directory already exists, which makes the script safe to re-run.
