# Linux Fundamentals Homework

## 1. Soft links and hard links

```bash
mkdir -p ~/linux-links
printf "hello\n" > ~/linux-links/original.txt
ln ~/linux-links/original.txt ~/linux-links/hard-link.txt
ln -s ~/linux-links/original.txt ~/linux-links/soft-link.txt
ls -li ~/linux-links
rm ~/linux-links/soft-link.txt
rm ~/linux-links/hard-link.txt
```

A hard link shares the inode and remains valid if the original name is removed. A
soft link stores a path, has a different inode, and becomes dangling when its
target is removed.

## 2. `adduser` versus `useradd`

`useradd` is a low-level utility and normally needs explicit options for the home
directory, shell, and password. `adduser` is an Ubuntu/Debian-friendly
interactive wrapper that applies sensible defaults and creates the home directory.

```bash
sudo adduser devops-demo
id devops-demo
sudo userdel -r devops-demo
```

## 3. `journalctl`

`journalctl` reads systemd's journal. These commands inspect all logs, the current
boot, and a particular service:

```bash
sudo journalctl -b
sudo journalctl -u ssh --since "today"
sudo journalctl -u docker -n 50 --no-pager
```

## 4. Command practice

```bash
pwd; ls -la; find . -maxdepth 2 -type f
grep -R "error" /var/log 2>/dev/null | head
df -h; free -h; ps aux --sort=-%mem | head
ip addr; ss -tuln; curl -I https://example.com
```
