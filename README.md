# DevOps Homework

My submissions for the DevOps sessions. Every command output in these files was run on my own machine (Kali Linux, Docker 28.5.2) and pasted as is - nothing is copied from the slides.

## Homework doc
https://docs.google.com/document/d/1cjXFYf2Thm8cBEN-0C48B-v02cj3jGLd47lcO18prHE/edit?usp=sharing

## Index

| session | topic | submission |
|---|---|---|
| 2 | Linux fundamentals | [session2-linux/README.md](session2-linux/README.md) |
| 3 | Shell scripting | [session3-shell-scripting/README.md](session3-shell-scripting/README.md) · [sysinfo.sh](session3-shell-scripting/sysinfo.sh) |
| 4 | Networking | [session4-networking/README.md](session4-networking/README.md) |
| 5 | Git / GitHub | [session5-git-github/README.md](session5-git-github/README.md) |
| 6-7 | Docker + multi-stage builds | [session6-7-docker/README.md](session6-7-docker/README.md) · [submission.md](session6-7-docker/submission.md) |
| 8 | Docker networking & volumes | [session8-docker-networking-volume/README.md](session8-docker-networking-volume/README.md) |

## What's in each session

**Session 2 - Linux.** Soft vs hard links proven with inode numbers and by deleting the target, `adduser` vs `useradd` run side by side as root, `journalctl` filters, and the command cheat sheet practiced with output.

**Session 3 - Shell scripting.** `sysinfo.sh` - prints date, hostname, username, disk usage and processes, takes input with `read -p`, and writes `ps aux` to a file with `>`.

**Session 4 - Networking.** 16 commands run for real - the `ip` family, ping, traceroute, ss, netstat, dig/nslookup/host, curl, wget, nc - with what each one told me and how they fit into a troubleshooting order.

**Session 5 - Git.** `git commit -m` vs `-a -m` including the case where `-a` refuses a new file, then a cherry-pick from a feature branch onto main with the `--graph` output showing the picked commit got a new hash.

**Session 6-7 - Docker.** Six Hello World apps (Node, Python, Java, Apache, React, Nginx), each with a Dockerfile, all built and verified. Plus the multi-stage task on port 8080, with an actual measurement of what multi-stage saves (React: 336MB build stage -> 162MB final).

**Session 8 - Docker networking & volumes.** Three networks with the backend attached to two of them, connectivity proven in both directions and proven *not* to work where there's no shared network. Apache on the host network on port 80. A bind mount edited live with no restart. Overlay networks written up. `reproduce.sh` runs the whole thing.

## Running things yourself

```bash
# session 3
cd session3-shell-scripting && ./sysinfo.sh

# session 6-7
cd session6-7-docker
docker build -t nodejs-app ./nodejs-app && docker run -d -p 3001:3000 nodejs-app

# session 8 - all four tasks end to end
cd session8-docker-networking-volume
./reproduce.sh          # run everything
./reproduce.sh clean    # tear it down
```
