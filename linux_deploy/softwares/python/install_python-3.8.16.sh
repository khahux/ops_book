#!/bin/bash

set -e

# apt install gcc make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
#     libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils \
#     tk-dev libffi-dev liblzma-dev libgdbm-dev libgdbm-compat-dev

VERSION="3.8.16"
rootPath="/data/server"

if [ -d ${rootPath}/python ];then
    echo "python已安装，需手动删除目录后才能安装: ${rootPath}/python"
    exit 0
fi

if [ -d ${rootPath}/python-${VERSION} ];then
    echo "python已安装，需手动删除目录后才能安装: ${rootPath}/python-${VERSION}"
    exit 0
fi

mkdir -p /data/server/python-${VERSION}
ln -s /data/server/python-${VERSION} /data/server/python


rm -rf Python-${VERSION}
if [ ! -f Python-${VERSION}.tgz ];then
    #wget https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz
    wget https://repo.huaweicloud.com/python/${VERSION}/Python-${VERSION}.tgz
fi
tar zxvf Python-${VERSION}.tgz
cd Python-${VERSION}
./configure --prefix=/data/server/python
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install

ln -s /data/server/python/bin/python3.8 /data/server/python/bin/python
ln -s /data/server/python/bin/pip3.8 /data/server/python/bin/pip

if ! grep "/data/server/python/bin" /etc/profile > /dev/null; then
    echo "'export PATH=/data/server/python/bin:\$PATH' >> /etc/profile"
    echo 'export PATH=/data/server/python/bin:$PATH' >> /etc/profile
    export PATH=/data/server/python/bin:$PATH
fi

${rootPath}/python/bin/python -m pip config set global.index-url http://pypi.doubanio.com/simple/
${rootPath}/python/bin/python -m pip config set install.trusted-host pypi.doubanio.com
${rootPath}/python/bin/python -m pip install pip --upgrade
