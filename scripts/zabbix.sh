#!/bin/bash
source $PWD_Dir/globalfuncs.sh
source $PWD_Dir/globalvars.sh
Install_Zabbix(){
    useradd zabbix -s /sbin/nologin
    Tar_Cd ${Zabbix_Ver}.tar.gz $Zabbix_Ver
    ./configure --prefix=$Zabbix_Dir --enable-server --enable-agent --with-mysql --with-net-snmp --with-libcurl
    make && make install 
    mysql -uroot -pnew-password << EOF
    drop database if exists zabbix;
    create database zabbix default character set utf8;
EOF
    cd database/mysql 
    mysql -uroot -p zabbix < schema.sql
    mysql -uroot -p zabbix < images.sql
    mysql -uroot -p zabbix < data.sql
    ln -sf /usr/local/zabbix/etc/ etc/zabbix
    cp -rf frontends/php /data/webapp/nginx
    chown -R nginx.nginx /data/webapp/nginx
    chmod -R 755 /data/webapp/nginx
    cp -rf $PWD_Dir/../conf/zabbix.conf /usr/local/nginx/conf/
}

