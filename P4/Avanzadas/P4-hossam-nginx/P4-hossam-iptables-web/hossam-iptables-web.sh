#!/bin/bash

# Denegación implícita de todo el tráfico
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Manejar el tráfico de red entrante basado en el estado de las conexiones
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir el tráfico de red saliente basado en el estado de las conexiones
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Manejar el tráfico de red de la misma máquina
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Manejar tráfico HTTP y HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Permitir el tráfico de red saliente a los servidores web
iptables -A OUTPUT -p tcp -d 192.168.10.2 --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.168.10.2 --dport 443 -j ACCEPT

iptables -A OUTPUT -p tcp -d 192.168.10.3 --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.168.10.3 --dport 443 -j ACCEPT

iptables -A OUTPUT -p tcp -d 192.168.10.4 --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.168.10.4 --dport 443 -j ACCEPT

iptables -A OUTPUT -p tcp -d 192.168.10.5 --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.168.10.5 --dport 443 -j ACCEPT

iptables -A OUTPUT -p tcp -d 192.168.10.6 --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.168.10.6 --dport 443 -j ACCEPT

iptables -A OUTPUT -p tcp -d 192.168.10.7 --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.168.10.7 --dport 443 -j ACCEPT

iptables -A OUTPUT -p tcp -d 192.168.10.8 --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.168.10.8 --dport 443 -j ACCEPT

iptables -A OUTPUT -p tcp -d 192.168.10.9 --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.168.10.9 --dport 443 -j ACCEPT


iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 20 --connlimit-mask 32 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp --syn --dport 443 -m connlimit --connlimit-above 20 --connlimit-mask 32 -j REJECT --reject-with tcp-reset

iptables -A INPUT -p tcp --dport 80 -m recent --update --seconds 60 --hitcount 10 --name HTTP -j DROP
iptables -A INPUT -p tcp --dport 443 -m recent --update --seconds 60 --hitcount 10 --name HTTP -j DROP

iptables -A INPUT -f -j DROP

iptables -A INPUT -p icmp --fragment -j DROP
