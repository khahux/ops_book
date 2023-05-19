#!/bin/bash

version="2.40.1"

# yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker
# apt install make libghc-zlib-dev libexpat1-dev libssl-dev libcurl4-gnutls-dev gettext unzip libcurl4-openssl-dev -y

if [ ! -f v${version}.tar.gz ];then
    wget https://github.com/git/git/archive/v${version}.tar.gz
fi

tar -zxvf v${version}.tar.gz
cd git-${version}

make prefix=/usr/local all
make prefix=/usr/local install

