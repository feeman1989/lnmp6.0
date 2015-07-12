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
    mysql -uroot -pnew-password zabbix < database/mysql/schema.sql
    mysql -uroot -pnew-password zabbix < database/mysql/images.sql
    mysql -uroot -pnew-password zabbix < database/mysql/data.sql
    ln -sf /usr/local/zabbix/etc/ etc/zabbix
    \cp -rf frontends/php /data/webapp/zabbix
    chown -R nginx.nginx /data/webapp/zabbix
    chmod -R 755 /data/webapp/zabbix
    \cp -rf $PWD_Dir/conf/zabbix.conf /usr/local/nginx/conf/
	\cp -rf /{zabbix_server,zabbix_agentd} /etc/init.d/
	#sed -i "s@^ZABBIX_BIN=.*@ZABBIX_BIN=\"/usr/local/zabbix/sbin/zabbix_agentd\"@" /etc/init.d/zabbix_agentd
	#sed -i "s@^ZABBIX_BIN=.*@ZABBIX_BIN=\"/usr/local/zabbix/sbin/zabbix_server\"@" /etc/init.d/zabbix_server
	#sed -i "/^ZABBIX_BIN=.*/ a\ZABBIX_CONFIG=\"/usr/local/zabbix/etc/zabbix_server.conf\"" /etc/init.d/zabbix_server
	#sed -i "/^ZABBIX_BIN=.*/ a\ZABBIX_CONFIG=\"/usr/local/zabbix/etc/zabbix_agentd.conf\"" /etc/init.d/zabbix_agentd
	
	echo "zabbix-agent 10050/tcp # Zabbix Agent" >> /etc/services
	echo "zabbix-agent 10050/udp # Zabbix Agent" >> /etc/services
	echo "zabbix-trapper 10051/tcp # Zabbix Trapper" >> /etc/services
	echo "zabbix-trapper 10051/udp # Zabbix Trapper" >> /etc/services
	
	
 
}

