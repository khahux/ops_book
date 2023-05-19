#!/bin/bash

goVersion="1.20.4"
rootPath="/data/server"

if [ -d ${rootPath}/go ];then
    echo "go已安装，需手动删除目录后才能安装: ${rootPath}/go"
    exit 0
fi

if [ -d ${rootPath}/go-${goVersion} ];then
    echo "go已安装，需手动删除目录后才能安装: ${rootPath}/go-${goVersion}"
    exit 0
fi

mkdir -p /data/server/go-${goVersion}
ln -s /data/server/go-${goVersion} /data/server/go

rm -rf tmp_go
if [ ! -f go${goVersion}.linux-amd64.tar.gz ];then
    # wget https://go.dev/dl/go${goVersion}.linux-amd64.tar.gz
    wget https://mirrors.aliyun.com/golang/go${goVersion}.linux-amd64.tar.gz
fi
mkdir tmp_go
tar xzf go${goVersion}.linux-amd64.tar.gz -C tmp_go
mv tmp_go/go/* /data/server/go-${goVersion}

if ! grep "GOROOT" /etc/profile > /dev/null; then
    echo "'export GOROOT=/data/server/go' >> /etc/profile"

    echo 'export GOROOT=/data/server/go' >> /etc/profile
    export GOROOT=/data/server/go 
    
    echo "'export PATH=\$GOROOT/bin:\$PATH' >> /etc/profile"
    echo 'export PATH=$GOROOT/bin:$PATH' >> /etc/profile
    
    export PATH=$GOROOT/bin:$PATH
fi
