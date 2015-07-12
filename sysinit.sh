#!/bin/bash
#initialize system
if [ -z $1 ];then
echo "`basename $0` hostname"
exit 0
fi
HostName="$1"
hostname $HostName
sed -i "s/^HOSTNAME=.*/HOSTNAME=$HostName/" /etc/sysconfig/network
echo 'PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\$ "' >> /etc/profile
# disabled selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0
#ulimit
echo 'ulimit -SHn 102400' >> /etc/profile
#kernel optimize
cp -rf ./conf/sysctl.conf /etc/
sysctl -p
