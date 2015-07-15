#!/bin/bash
PAR_Dir=$(cd `dirname $0`;cd ..;pwd)
source $PAR_Dir/globalvars.sh
Vsftp_Roles_Dir='/etc/vsftpd/roles'
Install_Vsftp(){
    /etc/init.d/vsftpd stop
	yum -y remove vsftpd db4-utils
	rm -rf /etc/vsftpd
	mkdir -p  $Vsftp_Roles_Dir
    useradd -s /sbin/nologin vftp -d $Vsftp_Dir
    chmod 700 $Vsftp_Dir
    test -f /etc/vsftpd/vsftpd.conf && mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.old
    \cp -rf $PAR_Dir/../conf/vsftpd.conf /etc/vsftpd/
    cat > /etc/vsftpd/accounts << EOF
    ftpdata
    123
EOF
    db_load -T -t hash -f /etc/vsftpd/accounts /etc/vsftpd/accounts.db
    chmod 0600 /etc/vsftpd/accounts.db
    echo 'db_load -T -t hash -f /etc/vsftpd/accounts /etc/vsftpd/accounts.db' > /etc/vsftpd/createu.sh
    echo 'chmod 0600 /etc/vsftpd/accounts.db' >> /etc/vsftpd/createu.sh
    chmod u+x /etc/vsftpd/createu.sh
    test $(/usr/bin/getconf LONG_BIT) -eq 64 && logBit=64
    cat > /etc/pam.d/vsftpd.vu << EOF
    #%PAM-1.0
    auth       sufficient     /lib${logBit:+64}/security/pam_userdb.so db=/etc/vsftpd/accounts
    account    sufficient     /lib${logBit:+64}/security/pam_userdb.so db=/etc/vsftpd/accounts
EOF
    > /etc/vsftpd/chroot_list
    cat > /etc/vsftpd/roles/ftpdata << EOF
    local_root=/data/ftpdata
    anon_world_readable_only=no
    write_enable=yes
    anon_upload_enable=no
    virtual_use_local_privs=yes
    anon_mkdir_write_enable=no
EOF
    cat > /etc/vsftpd/issue << EOF
    ==== Welcome to use mercury ftp server ====
EOF
    /etc/init.d/vsftpd start
}

Install_Vsftp