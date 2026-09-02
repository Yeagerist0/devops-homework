# Networking Homework - Commands & Output

Task 2: ran the networking commands on my machine, pasted the real output and wrote down what I understood from each one.

Machine: Linux (Kali), single wifi interface `wlan0`. MAC addresses are partially masked.

---

## 1. `ip addr` - show IP addresses

```
$ ip -br addr show
lo               UNKNOWN        127.0.0.1/8 ::1/128
wlan0            UP             100.129.173.211/20 fe80::965b:e3e0:1604:e196/64
docker0          DOWN           172.17.0.1/16
br-82e0a37528d9  UP             172.22.0.1/16
```

```
$ ip addr show wlan0
2: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 58:cd:c9:xx:xx:xx brd ff:ff:ff:ff:ff:ff
    inet 100.129.173.211/20 brd 100.129.175.255 scope global dynamic noprefixroute wlan0
       valid_lft 85605sec preferred_lft 85605sec
    inet6 fe80::965b:e3e0:1604:e196/64 scope link noprefixroute
```

This is the modern replacement for `ifconfig`. `-br` gives the short one line per interface version which is way easier to read.

Things i picked up from the full output:
- `/20` is the subnet mask, so 20 network bits and 12 host bits -> 4094 usable hosts in this range.
- `dynamic` means the address came from DHCP, not set by hand. `valid_lft 85605sec` is the DHCP lease time left.
- `lo` (127.0.0.1) is loopback, the machine talking to itself.
- `docker0` and the `br-*` ones are bridges docker made, each docker network gets its own subnet.

## 2. `ip link` - interfaces at layer 2

```
$ ip -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
wlan0            UP             58:cd:c9:xx:xx:xx <BROADCAST,MULTICAST,UP,LOWER_UP>
docker0          DOWN           9a:10:be:xx:xx:xx <NO-CARRIER,BROADCAST,MULTICAST,UP>
vethec4394e@if2  UP             4e:16:ad:xx:xx:xx <BROADCAST,MULTICAST,UP,LOWER_UP>
```

`ip addr` shows the IP (layer 3), `ip link` shows the interface itself and its MAC (layer 2). The `veth*` ones are the virtual cables docker uses to plug a container into a bridge, one end in the container one end on the host.

To bring an interface up or down: `sudo ip link set wlan0 down` / `sudo ip link set wlan0 up`.

## 3. `ip -s link` - interface statistics

```
$ ip -s link show wlan0
2: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
    RX:  bytes packets errors dropped  missed   mcast
     180287899  204814      0     544       0       0
    TX:  bytes packets errors dropped carrier collsns
      42751060   91366      0       0       0       0
```

Packet counters for the interface. Useful when something feels broken, if `errors` or `dropped` keeps climbing the problem is the link/driver, not the app.

## 4. `ip route` - routing table

```
$ ip route
default via 100.129.160.1 dev wlan0 proto dhcp src 100.129.173.211 metric 600
100.129.160.0/20 dev wlan0 proto kernel scope link src 100.129.173.211 metric 600
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown
172.22.0.0/16 dev br-82e0a37528d9 proto kernel scope link src 172.22.0.1
```

The kernel reads this top to bottom to decide where a packet goes. `default via 100.129.160.1` is the gateway, anything that doesn't match a more specific route gets handed to the router. The `100.129.160.0/20` line is the local LAN, those are reachable directly without the gateway.

## 5. `ip route get` - which route will this address take

```
$ ip route get 8.8.8.8
8.8.8.8 via 100.129.160.1 dev wlan0 src 100.129.173.211 uid 1000
    cache
```

Instead of me reading the whole table and guessing, this asks the kernel directly. It answers: goes out of wlan0, through the gateway, using this source IP.

## 6. `ip neigh` - ARP table

```
$ ip neigh
100.129.160.1 dev wlan0 lladdr f4:1e:57:xx:xx:xx REACHABLE
fe80::8c0:c984:f258:42d4 dev wlan0 lladdr 14:b5:cd:xx:xx:xx STALE
```

ARP maps an IP to a MAC on the local network. My machine knows the gateway's IP from DHCP but it needs the MAC to actually build a frame, so it asks "who has 100.129.160.1" and caches the answer here. `REACHABLE` = confirmed recently, `STALE` = cached but not verified lately.

## 7. `hostname`

```
$ hostname
SudoMatrix
$ hostname -I
100.129.173.211 172.21.0.1 172.17.0.1 172.19.0.1 172.22.0.1 172.18.0.1 172.20.0.1
```

`hostname -I` just dumps every IP the box has, quickest way to grab your own IP without reading `ip addr`.

## 8. `ping` - is the host alive

```
$ ping -c 4 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=8.67 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=8.58 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=117 time=10.1 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=117 time=8.33 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3006ms
rtt min/avg/max/mdev = 8.325/8.906/10.052/0.673 ms
```

Sends ICMP echo requests. `0% packet loss` = the path works. `time` is round trip. `ttl=117` is interesting, it started at 128 and got decremented once per router, so roughly 11 hops away.

I always ping the gateway first, then 8.8.8.8, then a domain name. If the gateway works but 8.8.8.8 doesn't the problem is upstream, if 8.8.8.8 works but google.com doesn't its DNS.

## 9. `traceroute` - the path to a host

```
$ traceroute -m 12 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 12 hops max, 60 byte packets
 1  wifi.height8tech.com (100.129.160.1)  55.729 ms  55.602 ms  55.562 ms
 2  202.131.133.5.convergentindia.com (202.131.133.5)  55.540 ms  55.504 ms
 3  115.117.125.189.static-mumbai.vsnl.net.in (115.117.125.189)  58.105 ms
 4  * 172.28.117.90 (172.28.117.90)  58.025 ms *
 5  115.112.15.114.static-chennai.vsnl.net.in (115.112.15.114)  54.304 ms
 6  * * *
 7  dns.google (8.8.8.8)  17.239 ms  24.116 ms  22.872 ms
```

Shows every router in between by sending packets with a TTL of 1, then 2, then 3 and so on, each router that drops one replies and reveals itself. You can literally read the path here: my router -> local ISP -> Mumbai -> Chennai -> google. The `* * *` at hop 6 just means that router is configured not to reply, not that its broken.

## 10. `ss` - socket statistics

```
$ ss -tuln
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:Port
tcp   LISTEN 0      4096         0.0.0.0:8000       0.0.0.0:*
tcp   LISTEN 0      4096         0.0.0.0:3000       0.0.0.0:*
tcp   LISTEN 0      4096       127.0.0.1:46243      0.0.0.0:*
```

```
$ ss -tn state established
Recv-Q Send-Q   Local Address:Port     Peer Address:Port
0      0      100.129.173.211:53584   104.18.31.173:443
0      0      100.129.173.211:60282   140.82.114.25:443
```

`ss` replaced `netstat` for sockets. Flags: `-t` tcp, `-u` udp, `-l` listening only, `-n` numeric ports (don't resolve to names).

The difference between `0.0.0.0:8000` and `127.0.0.1:46243` matters a lot: 0.0.0.0 means listening on every interface so anyone on the network can reach it, 127.0.0.1 means only this machine can. This is the command i use to answer "what is already using port 8080".

## 11. `netstat -rn`

```
$ netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         100.129.160.1   0.0.0.0         UG        0 0          0 wlan0
100.129.160.0   0.0.0.0         255.255.240.0   U         0 0          0 wlan0
172.17.0.0      0.0.0.0         255.255.0.0     U         0 0          0 docker0
```

Same routing table as `ip route`, older format. `0.0.0.0` destination = the default route, `U` = up, `G` = goes through a gateway. netstat is deprecated in favour of `ip` and `ss` but it still shows up everywhere so worth knowing.

## 12. `nslookup` / `dig` / `host` - DNS

```
$ nslookup google.com
Server:		100.129.160.1
Address:	100.129.160.1#53

Non-authoritative answer:
Name:	google.com
Address: 142.251.221.238
Name:	google.com
Address: 2404:6800:4009:82e::200e
```

```
$ dig +noall +answer google.com
google.com.		189	IN	A	142.251.221.238

$ dig +short MX google.com
10 smtp.google.com.

$ host github.com
github.com has address 20.207.73.82
github.com mail is handled by 0 github-com.mail.protection.outlook.com.
```

All three resolve a name to an IP, they just differ in verbosity. `dig` is the most precise, `+short` gives just the answer and `+noall +answer` gives only the answer section. The `189` in the dig output is the TTL, how many more seconds this answer can be cached.

"Non-authoritative" means my router's resolver gave me a cached copy, it isn't google's own nameserver.

## 13. `/etc/resolv.conf` - which DNS server am i using

```
$ cat /etc/resolv.conf
nameserver 100.129.160.1
nameserver 8.8.8.8
```

The resolver reads this file top down. First entry is my router (came from DHCP), 8.8.8.8 is the fallback. If DNS is failing this is the first file to check.

## 14. `curl` - make an actual HTTP request

```
$ curl -sI https://example.com
HTTP/2 200
date: Wed, 02 Sep 2026 04:43:36 GMT
content-type: text/html
server: cloudflare
last-modified: Sun, 30 Aug 2026 04:11:49 GMT
```

```
$ curl -s -o /dev/null -w 'http_code=%{http_code}\ndns=%{time_namelookup}s\nconnect=%{time_connect}s\ntls=%{time_appconnect}s\ntotal=%{time_total}s\n' https://example.com
http_code=200
dns=0.045586s
connect=0.056700s
tls=0.082157s
total=0.099808s
```

`-I` sends a HEAD request so you get only headers, good for checking if a service is up without downloading the page. The `-w` version was the useful bit for me, it breaks the request into stages so you can see whether slowness is DNS, the TCP connect or the TLS handshake. Here DNS took 45ms out of a 99ms total.

## 15. `wget --spider`

```
$ wget -q --spider -S https://example.com
  HTTP/1.1 200 OK
  Date: Wed, 02 Sep 2026 04:43:36 GMT
  Content-Type: text/html
  Connection: keep-alive
  Server: cloudflare
```

`--spider` checks the URL exists without saving the file, `-S` prints the response headers. wget is more of a downloader, curl is better for poking APIs.

## 16. `nc` (netcat) - is the port open

```
$ nc -zv 8.8.8.8 53
dns.google [8.8.8.8] 53 (domain) open
```

`-z` just scans without sending data, `-v` prints the result. ping only tells you the host is alive, this tells you a specific port is actually accepting connections. Handy when a container is running but the app inside it isn't listening yet.

---

## What i took away

The commands split roughly into layers, and troubleshooting works best going bottom up:

| layer | question | command |
|---|---|---|
| link | is the interface up, do i have a MAC | `ip link`, `ip -s link` |
| network | do i have an IP, do i have a route | `ip addr`, `ip route`, `ip neigh` |
| reachability | can i reach the other host | `ping`, `traceroute` |
| transport | is the port actually open | `ss -tuln`, `nc -zv` |
| naming | does the name resolve | `dig`, `nslookup`, `/etc/resolv.conf` |
| application | does the service answer properly | `curl -I`, `wget --spider` |

Old command -> new command: `ifconfig` -> `ip addr`, `route` -> `ip route`, `arp` -> `ip neigh`, `netstat` -> `ss`.
