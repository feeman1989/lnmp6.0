#!/bin/bash

IPTABLES=`which iptables`
$IPTABLES -t filter -P INPUT ACCEPT
$IPTABLES -t filter -P OUTPUT ACCEPT
$IPTABLES -t filter -P FORWARD ACCEPT
$IPTABLES -t filter -F
$IPTABLES -t nat -F
$IPTABLES -t filter -P INPUT DROP
$IPTABLES -t filter -P FORWARD DROP
$IPTABLES -t filter -P OUTPUT ACCEPT
$IPTABLES -t filter -A INPUT -i lo -j ACCEPT
$IPTABLES -t filter -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
/etc/init.d/iptables save
