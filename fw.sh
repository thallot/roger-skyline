#Clean up
sudo iptables -t filter -F
sudo iptables -t filter -X

#Block all
sudo iptables -t filter -P INPUT DROP
sudo iptables -t filter -P FORWARD DROP
sudo iptables -t filter -P OUTPUT DROP

#Keep already known connections
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

#Accept Loopback connection
sudo iptables -t filter -A INPUT -i lo -j ACCEPT
sudo iptables -t filter -A OUTPUT -o lo -j ACCEPT

#Refuse ICMP requests (ping)
sudo iptables -t mangle -A PREROUTING -p icmp -j DROP
sudo iptables -t filter -A INPUT -p icmp -j DROP
sudo iptables -t filter -A OUTPUT -p icmp -j DROP

#Accept SSH connections on port 2222
sudo iptables -t filter -A INPUT -p tcp --dport 2222 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --dport 2222 -j ACCEPT

#Accept HTTP on port 80
sudo iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT

#Accept HTTPS on port 443 and 8443
sudo iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 8443 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT

#Accept SMTP on port 25
sudo iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT

#Accept DNS on port 53
sudo iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
sudo iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT

#Block invalid packets
sudo iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

#Block new packets without flag tcp syn
sudo iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

#Block anormal sized packets (Maximum Segment Size)
sudo iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

#Block packets with fake TCP flags
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

#Block fragmented packets
sudo iptables -t mangle -A PREROUTING -f -j DROP

#Limits new connections in time /client (flood)
sudo iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
sudo iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP

#Limits max connections/client to 50
sudo iptables -A INPUT -p tcp -m connlimit --connlimit-above 50 --connlimit-mask 16 -j REJECT --reject-with tcp-reset

#Limits max connections/min to 25
sudo iptables -A INPUT -p tcp --dport 443 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

#Protection Synflood
sudo iptables -A INPUT -p tcp --syn -m limit --limit 2/s --limit-burst 2 -j ACCEPT

#Protection Pingflood
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT

#Protection port scanning
sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 1/h -j ACCEPT
