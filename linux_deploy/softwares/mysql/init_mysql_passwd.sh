#!/bin/bash

newPassword=""
rootPath="/data/server"

function gen_password()
{
	MATRIX="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~!@$%^&*()_+="
	LENGTH=$1
	while [ "${n:=1}" -le "$LENGTH" ]
	do
	        newPassword="$newPassword${MATRIX:$(($RANDOM%${#MATRIX})):1}"
	        let n+=1
	done
	return 0
}

gen_password 32

tmpPassword=$(cat ${rootPath}/mysql/log/error.log | grep 'A temporary password is generated for root@localhost' | awk '{print $NF}');
${rootPath}/mysql/bin/mysql -uroot -p$tmpPassword --connect-expired-password -e "SET PASSWORD = PASSWORD('$newPassword');  ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER; FLUSH PRIVILEGES;"

echo "generate mysql passwd to : ${rootPath}/mysql/support-files/psw"
echo "mysql_password: $newPassword" > ${rootPath}/mysql/support-files/psw
chmod 600 ${rootPath}/mysql/support-files/psw
