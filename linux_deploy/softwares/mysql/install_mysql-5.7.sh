#!/bin/bash

# apt install libnuma-dev libncurses5
# yum install numactl

mysqlVersion="5.7.41"
rootPath="/data/server"

mysql_online=$(ps aux | grep '${rootPath}/mysql/bin/mysqld' | grep -v grep)
if [ "${mysql_online}" != "" ];then
    echo "mysql进程存在，可能数据需要备份，需手动停止服务: /etc/init.d/mysqld stop"
    exit 0
fi

if [ -d ${rootPath}/mysql ];then
    echo "mysql存在数据，需手动删除目录后才能安装: ${rootPath}/mysql"
    exit 0
fi
if [ -d ${rootPath}/mysql-${mysqlVersion} ];then
    echo "mysql存在数据，需手动删除目录后才能安装: ${rootPath}/mysql-${mysqlVersion}"
    exit 0
fi
mkdir ${rootPath}/mysql-${mysqlVersion}
ln -s ${rootPath}/mysql-${mysqlVersion} ${rootPath}/mysql

ifubuntu=$(cat /proc/version | grep ubuntu)
if14=$(cat /etc/issue | grep 14)

if [ `uname -m` == "x86_64" ];then
    machine=x86_64
else
    machine=i686
fi
if [ $machine == "x86_64" ];then
    rm -rf mysql-${mysqlVersion}-linux-glibc2.12-x86_64
    if [ ! -f mysql-${mysqlVersion}-linux-glibc2.12-x86_64.tar.gz ];then
        # wget https://mirrors.cloud.tencent.com/mysql/downloads/MySQL-5.7/mysql-${mysqlVersion}-linux-glibc2.12-x86_64.tar.gz
        wget https://downloads.mysql.com/archives/get/p/23/file/mysql-${mysqlVersion}-linux-glibc2.12-x86_64.tar.gz
    fi
    tar -xzvf mysql-${mysqlVersion}-linux-glibc2.12-x86_64.tar.gz
    mv mysql-${mysqlVersion}-linux-glibc2.12-x86_64/* ${rootPath}/mysql
else
    rm -rf mysql-${mysqlVersion}-linux-glibc2.12-i686
    if [ ! -f mysql-${mysqlVersion}-linux-glibc2.12-i686.tar.gz ];then
        https://mirrors.cloud.tencent.com/mysql/downloads/MySQL-5.7/mysql-${mysqlVersion}-linux-glibc2.12-i686.tar.gz
    fi
    tar -xzvf mysql-${mysqlVersion}-linux-glibc2.12-i686.tar.gz
    mv mysql-${mysqlVersion}-linux-glibc2.12-i686/* ${rootPath}/mysql
fi

if [ -f  /etc/mysql/my.cnf ];then
    mv /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
fi

if [ -f /etc/my.cnf ];then
    mv /etc/my.cnf /etc/my.cnf.bak
fi

cat > ${rootPath}/mysql/my.cnf <<END
[client]
port            = 5807
socket          = /tmp/mysql.sock
[mysqld]
port            = 5807
socket          = /tmp/mysql.sock
skip-external-locking
log-error=${rootPath}/mysql/log/error.log
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

log-bin=mysql-bin
binlog_format=mixed
server-id       = 1

sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash
explicit_defaults_for_timestamp=true

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
END

groupadd mysql
useradd -g mysql -s /sbin/nologin mysql

mkdir -p ${rootPath}/mysql/log
touch ${rootPath}/mysql/log/error.log
chown -R mysql:mysql ${rootPath}/mysql/log

${rootPath}/mysql/bin/mysqld --defaults-file=${rootPath}/mysql/my.cnf --basedir=${rootPath}/mysql --datadir=${rootPath}/mysql/data/ --user=mysql --initialize
chown -R mysql:mysql ${rootPath}/mysql/
chown -R mysql:mysql ${rootPath}/mysql/data/

cp -f ${rootPath}/mysql/support-files/mysql.server /etc/init.d/mysqld
sed -i "s#^basedir=\$#basedir=${rootPath}/mysql#" /etc/init.d/mysqld
sed -i "s#^datadir=\$#datadir=${rootPath}/mysql/data#" /etc/init.d/mysqld

chmod 755 /etc/init.d/mysqld
/etc/init.d/mysqld start

#开机启动
if ! cat /etc/rc.local | grep "/etc/init.d/mysqld" > /dev/null;then
    echo "/etc/init.d/mysqld start" >> /etc/rc.local
fi
sleep 10s
./init_mysql_passwd.sh

if ! grep "mysql/bin" /etc/profile > /dev/null; then
    echo "'export PATH=${rootPath}/mysql/bin:\$PATH' >> /etc/profile"
    echo "export PATH=${rootPath}/mysql/bin:\$PATH" >> /etc/profile
fi
