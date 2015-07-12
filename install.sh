#!/bin/bash
PWD_Dir=$(cd $(dirname $0);pwd)
source $PWD_Dir/globalvars.sh
Tar_Cd(){
	local FileName=$1
	local DirName=$2
	cd $PWD_Dir/packets
	[[ -d $DirName ]] && rm -rf $DirName
	tar zxvf $FileName
	cd $DirName
}
Install_PCRE(){
	Tar_Cd ${PCRE_Ver}.tar.gz $PCRE_Ver
    ./configure
     make && make install
}
Install_Nginx(){
	groupadd nginx
	useradd -s /sbin/nologin/ -g nginx nginx
	Tar_Cd ${Nginx_Ver}.tar.gz $Nginx_Ver
	./configure --user=nginx --group=nginx --prefix=$Nginx_Dir --with-pcre --with-http_stub_status_module --with-http_ssl_module --with-http_spdy_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module
	make && make install
    echo "export PATH=$PATH:$Nginx_Dir/sbin" >> /etc/profile
    source /etc/profile
	echo '/usr/local/lib' >> /etc/ld.so.conf
	ldconfig
    mv $Nginx_Dir/conf/nginx.conf $Nginx_Dir/conf/nginx.conf.old
    \cp -rf $PWD_Dir/conf/nginx.conf $Nginx_Dir/conf/
    \cp -rf $PWD_Dir/init.d/nginx /etc/init.d/nginx
    chmod +x /etc/init.d/nginx
    /etc/init.d/nginx start
}

Install_Mysql(){
	yum remove mysql mysql-server -y
	rm -f /etc/my.cnf 
	Tar_Cd ${Mysql_Ver}.tar.gz $Mysql_Ver
	patch -p1 < ../mysql-openssl.patch
	cmake -DCMAKE_INSTALL_PREFIX=$Mysql_Dir -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci \
	-DWITH_READLINE=1 -DWITH_SSL=bundled -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
    make && make install
    groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql
    \cp -f $PWD_Dir/conf/my.cnf /etc/my.cnf
	echo "export PATH=$PATH:$Mysql_Dir/bin" >> /etc/profile
	source /etc/profile
    /usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=$Mysql_Dir --datadir=/data/mysql --user=mysql
    \cp -f support-files/mysql.server /etc/init.d/mysqld
    chmod +x /etc/init.d/mysqld
    echo '/usr/local/mysql/lib' >> /etc/ld.so.conf.d/mysql.conf
	ldconfig
    ln -sf /usr/local/mysql/lib/mysql /usr/lib/mysql
    ln -sf /usr/local/mysql/include/mysql /usr/include/mysql
	/etc/init.d/mysqld start
	/usr/local/mysql/bin/mysqladmin -u root password 'new-password'
}

Install_PHP(){
	yum remove php -y
	Tar_Cd ${PHP_Ver}.tar.gz $PHP_Ver
	./configure --prefix=$PHP_Dir --with-config-file-path=$PHP_Dir/etc --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --with-mysql=mysqlnd \
        --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir \
        --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --disable-rpath --enable-bcmath \
        --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring \
        --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets\
        --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache
    make ZEND_EXTRA_LIBS='-liconv'
    make install
    \cp -f php.ini-production /usr/local/php/etc/php.ini
    ln -sf /usr/local/php/bin/php /usr/bin/php
    ln -sf /usr/local/php/bin/phpize /usr/bin/phpize
    ln -sf /usr/local/php/bin/pear /usr/bin/pear
    ln -sf /usr/local/php/bin/pecl /usr/bin/pecl
    ln -sf /usr/local/php/sbin/php-fpm /usr/bin/php-fpm
    mv /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
    sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
	sed -i 's/max_input_time = 60/max_input_time = 300/g' /usr/local/php/etc/php.ini
	\cp -f $PWD_Dir/init.d/php-fpm /etc/init.d/
	/etc/init.d/php-fpm start

}
