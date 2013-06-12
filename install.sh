#!/bin/bash

# Author: Vincent

source ./make_conf.sh

cur=`pwd`

echo "Step 1: install openvpn...."
wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.04.tar.gz
if [ $? -ne 0 ]; then
	echo "Download lzo failed.";
	exit 1;
fi

wget http://swupdate.openvpn.net/community/releases/openvpn-2.1.4.tar.gz
if [ $? -ne 0 ]; then
	echo "Download openvpn failed.";
	exit 1;
fi

yum install -y openssl openssl-devel automake pkgconfig iptables gcc lrzsz make
if [ $? -ne 0 ]; then
	echo "yum install failed.";
	exit 1;
fi

tar zxvf lzo-2.04.tar.gz
if [ $? -ne 0 ]; then
	echo "tar failed.";
	exit 1;
fi
cd lzo-2.04/
./configure
if [ $? -ne 0 ]; then
	echo "configure failed.";
	exit 1;
fi
make && make check && make install
if [ $? -ne 0 ]; then
	echo "Install lzo failed.";
	exit 1;
fi
cd ../

tar zxvf openvpn-2.1.4.tar.gz
if [ $? -ne 0 ]; then
	echo "tar failed.";
	exit 1;
fi
cd openvpn-2.1.4
./configure --with-lzo-headers=/usr/local/include \
	 --with-lzo-lib=/usr/local/lib  \
	 --with-ssl-headers=/usr/include/openssl  \
	 --with-ssl-lib=/usr/lib
if [ $? -ne 0 ]; then
	echo "configure failed.";
	exit 1;
fi
make && make install
if [ $? -ne 0 ]; then
	echo "Install lzo failed.";
	exit 1;
fi
cd ../

echo "Step 2: copy rsa...."
cd openvpn-2.1.4
mkdir -p /etc/openvpn
cp -r easy-rsa /etc/openvpn/
if [ $? -ne 0 ]; then
	echo "copy easy-rsa failed.";
	exit 1;
fi

cd /etc/openvpn/easy-rsa/2.0/
cp openssl.cnf openssl.cnf.old
cp openssl-0.9.6.cnf openssl.cnf
if [ $? -ne 0 ]; then
	echo "cp openssl failed.";
	exit 1;
fi

echo "Step 3: install keys...."
cd /etc/openvpn/easy-rsa/2.0/
source vars
./clean-all
if [ $? -ne 0 ]; then
	echo "clean-all failed.";
	exit 1;
fi

./build-ca
if [ $? -ne 0 ]; then
	echo "build-ca failed.";
	exit 1;
fi

./build-key-server server
if [ $? -ne 0 ]; then
	echo "build-key-server failed.";
	exit 1;
fi

./build-key $client
if [ $? -ne 0 ]; then
	echo "build-key failed.";
	exit 1;
fi


$OPENSSL='openssl'
./build-dh
if [ $? -ne 0 ]; then
	echo "build-dh failed.";
	exit 1;
fi

cp -r keys $cur

iptables -t nat -A POSTROUTING -s 10.8.0.0/24  -j SNAT --to-source $ip
if [ $? -ne 0 ]; then
	echo "iptables failed.";
	exit 1;
fi

sysctl -w net.ipv4.ip_forward=1
/etc/init.d/iptables save
if [ $? -ne 0 ]; then
	echo "iptables save failed.";
	exit 1;
fi

/etc/init.d/iptables restart
if [ $? -ne 0 ]; then
	echo "iptables restart failed.";
	exit 1;
fi

cd $cur

cp server.conf /usr/local/etc/
cp ${client}.conf /usr/local/etc/

cp ${client}.conf keys/${client}.ovpn
tar -zcvf keys.tar.gz keys
sz -be keys.tar.gz

echo "Please exec: /usr/local/sbin/openvpn --config /usr/local/etc/server.conf"

