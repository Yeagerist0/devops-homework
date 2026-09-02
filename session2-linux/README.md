# Session 2 - Linux Fundamentals Homework

Everything below was run on my machine (Kali, kernel 7.1.5) and the output is pasted as is.

---

## Task 1: Soft Link & Hard Link

### Creating both

```
$ echo "this is the original file" > target.txt
$ ln    target.txt hardlink.txt      # hard link
$ ln -s target.txt softlink.txt      # soft link (symlink)

$ ls -li
4906 -rw-rw-r-- 2 hitarth hitarth 26 Sep  2 10:35 hardlink.txt
4907 lrwxrwxrwx 1 hitarth hitarth 10 Sep  2 10:35 softlink.txt -> target.txt
4906 -rw-rw-r-- 2 hitarth hitarth 26 Sep  2 10:35 target.txt
```

The first column is the inode. `target.txt` and `hardlink.txt` are both **4906** - same inode means it is literally the same file with two names. `softlink.txt` has its own inode 4907 and its size is 10 bytes, which is just the length of the string "target.txt", because that's all a symlink stores.

The `2` in the permissions column is the link count:

```
$ stat -c 'file=%n inode=%i links=%h size=%s' target.txt hardlink.txt softlink.txt
file=target.txt   inode=4906 links=2 size=26
file=hardlink.txt inode=4906 links=2 size=26
file=softlink.txt inode=4907 links=1 size=10
```

### Both see the same data

```
$ echo "line added later" >> target.txt

$ cat hardlink.txt
this is the original file
line added later

$ cat softlink.txt
this is the original file
line added later
```

### Deleting the original - this is the real difference

```
$ rm target.txt

$ ls -li
4906 -rw-rw-r-- 1 hitarth hitarth 43 Sep  2 10:35 hardlink.txt
4907 lrwxrwxrwx 1 hitarth hitarth 10 Sep  2 10:35 softlink.txt -> target.txt

$ cat hardlink.txt
this is the original file
line added later

$ cat softlink.txt
cat: softlink.txt: No such file or directory
```

The hard link survived and its link count dropped from 2 to 1. `rm` doesn't delete data, it removes one name and decrements the count - the data is only freed when the count hits 0. The symlink is now dangling, it still points at "target.txt" but nothing is there.

```
$ readlink softlink.txt
target.txt
```

### Directories

```
$ mkdir mydir
$ ln -s mydir dirlink
lrwxrwxrwx 1 hitarth hitarth 5 Sep  2 10:35 dirlink -> mydir

$ ln mydir dirhard
ln: mydir: hard link not allowed for directory
```

### Deleting a link

```
$ rm softlink.txt     # removes the link, not the target
$ rm hardlink.txt     # removes one name, data goes only if it was the last one
```

### Interview answer

A hard link is a second directory entry pointing at the same inode, so it is the same file - it survives deletion of the original, updates are shared, and there's no "original" vs "copy", both names are equal. A soft link is its own tiny file that just holds a path string, so it breaks the moment the target moves or is deleted.

Limits: hard links can't cross filesystems (an inode number only means something inside one filesystem) and can't point at directories (it would let you build loops the kernel can't safely walk). Symlinks can do both, which is why `/usr/bin/python3 -> python3.11` style links are always symlinks.

| | hard link | soft link |
|---|---|---|
| own inode | no, shares it | yes |
| survives deleting the target | yes | no, becomes dangling |
| across filesystems | no | yes |
| to a directory | no | yes |
| `ls -l` shows | a normal file | `link -> target` |

---

## Task 2: `adduser` vs `useradd`

I don't have passwordless sudo on this laptop, so I ran both commands as root inside an Ubuntu container. Same binaries, real output.

```
$ docker run --rm ubuntu:24.04 bash
# apt-get install -y adduser
```

### `useradd` on its own

```
# useradd testuser1
# grep testuser1 /etc/passwd
testuser1:x:1001:1001::/home/testuser1:/bin/sh

# ls /home
ubuntu
```

The account exists in `/etc/passwd` but **no home directory was created**, and the shell defaulted to `/bin/sh`. A user in that state can't really log in and work.

### `useradd` with the flags you actually need

```
# useradd -m -s /bin/bash testuser2
# grep testuser2 /etc/passwd
testuser2:x:1002:1002::/home/testuser2:/bin/bash

# ls -ld /home/testuser2
drwxr-x--- 2 testuser2 testuser2 4096 Sep  2 05:06 /home/testuser2
```

`-m` makes the home dir, `-s` sets the shell. You have to remember every one of these yourself.

### `adduser` - the recommended one on Ubuntu/Debian

```
# adduser --disabled-password --gecos "" testuser3
info: Adding user `testuser3' ...
info: Selecting UID/GID from range 1000 to 59999 ...
info: Adding new group `testuser3' (1003) ...
info: Adding new user `testuser3' (1003) with group `testuser3 (1003)' ...
info: Creating home directory `/home/testuser3' ...
info: Copying files from `/etc/skel' ...
info: Adding new user `testuser3' to supplemental / extra groups `users' ...
info: Adding user `testuser3' to group `users' ...

# grep testuser3 /etc/passwd
testuser3:x:1003:1003:,,,:/home/testuser3:/bin/bash

# ls -a /home/testuser3
.  ..  .bash_logout  .bashrc  .profile
```

Without any flags it made the group, the home directory, copied the skeleton dotfiles from `/etc/skel`, set a real shell and added the user to the right supplemental groups. Run interactively it also prompts for the password and the full name.

I used `--disabled-password --gecos ""` only so it wouldn't stop and wait for input inside a script.

### `adduser` is a wrapper, not a separate tool

```
# head -3 /usr/sbin/adduser
#! /usr/bin/perl

# Copyright (C) 2000-2004 Roland Bauerschmidt <rb@debian.org>

# grep -c "useradd" /usr/sbin/adduser
6
```

It's a Perl script that calls `useradd` underneath - which is exactly why the man page says `useradd` is the "low level utility".

### Which one to use

`adduser` on Ubuntu/Debian, because it applies the distro's policy for you and it's much harder to end up with a half-broken account. `useradd` is what you use in scripts and Dockerfiles where you want no prompts and full control, and it's the portable one (`adduser` doesn't exist on RHEL/Alpine in the same form).

```
sudo adduser testuser          # the recommended command on Ubuntu
```

---

## Task 3: `journalctl`

`journalctl` reads the binary log that `systemd-journald` collects - kernel messages, service stdout/stderr, and syslog all in one indexed place instead of scattered files in `/var/log`.

### Recent entries

```
$ journalctl -n 5 --no-pager
Sep 02 10:36:14 SudoMatrix kernel: veth1a7ef47 (unregistering): left allmulticast mode
Sep 02 10:36:14 SudoMatrix kernel: docker0: port 3(veth1a7ef47) entered disabled state
Sep 02 10:36:14 SudoMatrix systemd[1]: run-docker-netns-2f6b61225296.mount: Deactivated successfully.
```

### Logs for one service - the one I use most

```
$ journalctl -u NetworkManager -n 5 --no-pager
Sep 02 10:35:52 SudoMatrix NetworkManager[1190]: <info>  [1788325552.6202] device (vethe67f935): carrier: link connected
Sep 02 10:35:52 SudoMatrix NetworkManager[1190]: <info>  [1788325552.8278] manager: (vethc57b058): new Veth device
Sep 02 10:36:04 SudoMatrix NetworkManager[1190]: <info>  [1788325564.0315] manager: (veth1a7ef47): new Veth device
```

### This boot only

```
$ journalctl -b --no-pager | head
Sep 02 09:59:47 SudoMatrix kernel: Linux version 7.1.5+kali-amd64 ...
Sep 02 09:59:47 SudoMatrix kernel: Command line: BOOT_IMAGE=/boot/vmlinuz-7.1.5+kali-amd64 root=UUID=... ro quiet acpi_backlight=native splash
```

### Which boots are stored

```
$ journalctl --list-boots --no-pager
 -2 786575fb80d34d7393caf99a5e80fd2c Tue 2026-09-01 11:45:01 IST Tue 2026-09-01 19:59:05 IST
 -1 ad9644277d7a4cef8b6c02d8a2d0050c Tue 2026-09-01 20:40:30 IST Wed 2026-09-02 01:27:36 IST
  0 b39a9acdc54543189a8a38965e41948e Wed 2026-09-02 09:59:47 IST Wed 2026-09-02 10:36:14 IST
```

`0` is the current boot, `-1` is the previous one. `journalctl -b -1` reads the boot before this one, which is how you look at why a machine crashed.

### Errors only

```
$ journalctl -b -p err -n 5 --no-pager
Sep 02 10:01:05 SudoMatrix obexd[4569]: Unable to acquire registry: Error calling StartServiceByName for org.gnome.evolution.dataserver.Sources5: Unit evolution-source-registry.service not found.
Sep 02 10:27:47 SudoMatrix pkexec[42354]: PAM (polkit-1) /usr/lib/pam.d is not supported on this system
Sep 02 10:34:51 SudoMatrix sudo[49237]:  hitarth : a password is required ; PWD=/home/hitarth/devops-heros ; USER=root ; COMMAND=/usr/bin/true
```

### Kernel only, time filters, disk usage

```
$ journalctl -k -n 4 --no-pager
Sep 02 10:36:14 SudoMatrix kernel: docker0: port 3(veth1a7ef47) entered disabled state
Sep 02 10:36:14 SudoMatrix kernel: veth1a7ef47 (unregistering): left promiscuous mode

$ journalctl --since "1 hour ago" -n 3 --no-pager
Sep 02 10:36:14 SudoMatrix systemd[1]: run-docker-netns-2f6b61225296.mount: Deactivated successfully.

$ journalctl --disk-usage
Archived and active journals take up 450.5M in the file system.
```

### Flags worth remembering

| flag | what it does |
|---|---|
| `-u <service>` | only that unit's logs |
| `-f` | follow live, like `tail -f` |
| `-n N` | last N lines |
| `-b` / `-b -1` | this boot / previous boot |
| `-p err` | priority err and worse |
| `-k` | kernel messages only |
| `--since` / `--until` | time window, accepts "1 hour ago", "today" |
| `--no-pager` | don't open less, useful in scripts |
| `--disk-usage` | how much space the journal is eating |
| `--vacuum-time=7d` | delete logs older than 7 days |

The thing I actually took away: the journal is structured, not text. `-u`, `-p` and `--since` are real indexed filters, so instead of `grep`-ing through `/var/log/syslog` you ask for exactly the slice you want. And `-f` on a failing unit while you restart it is the fastest debugging loop there is.

---

## Task 4: Linux Command Cheat Sheet

Practiced the commands and captured the output.

### Navigating and creating

```
$ pwd
/tmp/.../cheat

$ mkdir -p project/src project/docs
$ touch project/src/main.py project/README.md
$ ls -R project
project:
docs  README.md  src

project/src:
main.py
```

`mkdir -p` makes parent directories and doesn't complain if they already exist.

### Copy, move, delete

```
$ cp project/README.md project/README.bak
$ mv project/README.bak project/docs/
$ ls project/docs
README.bak
$ rm project/docs/README.bak
```

`mv` is both "move" and "rename", it's the same operation.

### Permissions

```
$ ls -l run.sh
-rw-rw-r-- 1 hitarth hitarth 20 Sep  2 10:36 run.sh

$ chmod +x run.sh
$ ls -l run.sh
-rwxrwxr-x 1 hitarth hitarth 20 Sep  2 10:36 run.sh

$ stat -c '%n %a %U:%G' run.sh
run.sh 775 hitarth:hitarth
```

Three groups of rwx - owner, group, others. `775` is the same thing in octal. `chown user:group file` changes who owns it (needs root).

### Searching text

```
$ grep ERROR log.txt
beta ERROR here
delta ERROR again

$ grep -n ERROR log.txt
2:beta ERROR here
4:delta ERROR again

$ grep -c ERROR log.txt
2
```

`-n` line numbers, `-c` count, `-i` ignore case, `-r` recurse into directories, `-v` invert.

### Searching files

```
$ find project -type f -name '*.py'
project/src/main.py

$ find project -type d
project
project/docs
project/src
```

`grep` searches inside files, `find` searches for files. `-type f` files, `-type d` directories.

### Processes

```
$ ps aux | head -3
USER  PID %CPU %MEM    VSZ   RSS TTY STAT START TIME COMMAND
root    1  0.0  0.1  27436 17152 ?   Ss   09:59 0:01 /sbin/init splash
root    2  0.0  0.0      0     0 ?   S    09:59 0:00 [kthreadd]

$ ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -5
    PID COMMAND         %CPU %MEM
   1425 Xorg            14.8  1.6
  51739 zsh             12.5  0.0
  18632 WebExtensions   11.7  4.0
```

`ps` is a snapshot, `top`/`htop` is the live version.

### Disk

```
$ df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p8  233G  199G   22G  91% /

$ du -sh project
0	project
```

`df` = free space per filesystem, `du` = how much a directory is using. `-h` human readable on both.

### Archives

```
$ tar -czf project.tar.gz project
$ ls -lh project.tar.gz
-rw-rw-r-- 1 hitarth hitarth 207 Sep  2 10:36 project.tar.gz

$ tar -tzf project.tar.gz
project/
project/README.md
project/docs/
project/src/
project/src/main.py
```

`c` create, `x` extract, `t` list, `z` gzip, `f` file, `v` verbose.

### System info

```
$ uname -a
Linux SudoMatrix 7.1.5+kali-amd64 #1 SMP PREEMPT_DYNAMIC Kali 7.1.5-1kali1 x86_64 GNU/Linux

$ whoami
hitarth

$ id
uid=1000(hitarth) gid=1000(hitarth) groups=1000(hitarth),27(sudo),140(docker),...

$ uptime
 10:36:40 up 37 min,  1 user,  load average: 1.61, 1.17, 1.13

$ free -h
               total  used  free  shared  buff/cache  available
Mem:            14Gi  7.6Gi 1.0Gi   152Mi       6.8Gi       7.3Gi
```

`id` was useful here - it shows I'm in the `docker` group, which is why docker works without sudo.

### Quick reference

| area | commands |
|---|---|
| move around | `pwd`, `cd`, `ls`, `tree` |
| files | `touch`, `mkdir`, `cp`, `mv`, `rm`, `cat`, `head`, `tail`, `wc` |
| permissions | `chmod`, `chown`, `stat`, `umask` |
| search | `grep`, `find`, `locate`, `which` |
| processes | `ps`, `top`, `kill`, `jobs`, `bg`, `fg` |
| disk | `df`, `du`, `lsblk`, `mount` |
| archive | `tar`, `gzip`, `zip`, `unzip` |
| system | `uname`, `whoami`, `id`, `uptime`, `free`, `systemctl`, `journalctl` |
| network | `ip`, `ping`, `ss`, `dig`, `curl`, `wget`, `ssh`, `scp` |
