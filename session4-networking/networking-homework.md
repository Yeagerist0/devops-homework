# Networking Fundamentals Homework

The commands below were used for practice. Run them on a Linux host and paste
the output below each command when collecting screenshots/evidence.

```bash
ip addr
ip route
ip link
ping -c 4 8.8.8.8
getent hosts github.com
ss -tuln
traceroute github.com       # install traceroute if required
curl -I https://github.com
```

`ip addr` shows interfaces and addresses, `ip route` shows the routing table,
`ping` tests reachability, `getent hosts` tests DNS resolution, `ss` lists
listening sockets, `traceroute` shows the path, and `curl -I` tests HTTP headers.
