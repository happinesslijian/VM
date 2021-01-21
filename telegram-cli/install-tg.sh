#!/bin/sh 
cd /root/
yum update -y
yum -y install openssl-devel zlib-devel wget 
yum groupinstall "Development Tools"

wget -c https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
tar xf libevent-2.1.12-stable.tar.gz
cd libevent-2.1.12-stable
./configure --prefix=/usr --libdir=/usr/lib64
make
make install
yum -y install libtermcap-devel ncurses-devel libevent-devel readline-devel readline-devel.x86_64 libconfig-devel.x86_64 jansson-devel.x86_64
cd /root/
curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz
tar zxf lua-5.3.4.tar.gz
cd lua-5.3.4
make linux test
make install

cd /root/
git clone --recursive https://github.com/vysheng/tg.git
cd tg
./configure
make
cp /root/tg/bin/telegram-cli /root/
