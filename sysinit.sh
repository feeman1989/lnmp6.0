#!/bin/bash
# 系统初始化
CUR_DIR=$(cd `dirname $0`;pwd)
if [ -z $1 ]
then
  echo "USAGE:`basename $0` HOSTNAME"
  exit 0
fi
HOSTNAME="$1"
hostname $HOSTNAME
sed -i "s/^HOSTNAME=.*/HOSTNAME=$HOSTNAME/" /etc/sysconfig/network
echo 'export PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\$ "' >> /etc/profile

# 禁用SELINUX
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

# 设置ULIMIT
echo 'ulimit -SHn 65535' >> /etc/profile

# 设置历史记录
echo 'HISTSIZE=500' >> /etc/profile

# 设置内核
cp -rf $CUR_DIR/conf/sysctl.conf /etc/
sysctl -p
 
