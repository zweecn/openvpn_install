#!/bin/bash

export ip="x.x.x.x"
export client="client1"
export port="xxxxx"

###########################################################
echo "local ${ip}
port ${port}
proto udp
 
dev tun
  
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
   
server 10.8.0.0 255.255.255.0

duplicate-cn

client-to-client
keepalive 10 120
         
comp-lzo
          
persist-key
persist-tun
status /etc/openvpn/easy-rsa/2.0/keys/openvpn-status.log
verb 4
           
push \"dhcp-option DNS 8.8.8.8\"
push \"dhcp-option DNS 8.8.4.4\"
" > server.conf

echo "client

dev tun
proto udp
  
remote ${ip} ${port}
persist-key
persist-tun
ca ca.crt
cert ${client}.crt         
key ${client}.key
ns-cert-type server
comp-lzo
verb 3
   
redirect-gateway def1
route-method exe
route-delay 2
" > ${client}.conf

cp ${client}.conf ${client}.ovpn
