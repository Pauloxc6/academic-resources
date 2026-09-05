#!/usr/bin/env bash
#limpa todas as regras de firewall
iptables -F
iptables -t nat -F
iptables -t mangle -F

#A linha abaixo ativa o modulo do netfilter que evita ataques Dos
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

#libera portas dos serviços necessarios
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT

iptables -A INPUT -p udp --dport 53 -j ACCEPT

#A linha faz o bloquei de conexoes das demais portas
iptables -A INPUT -p tcp --syn -j DROP

#Faz o encaminhamento dos pacotes
echo 1 > /proc/sys/net/ipv4/ip_forward
