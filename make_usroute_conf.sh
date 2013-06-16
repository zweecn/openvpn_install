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

echo "max-routes 60
route-nopull

client

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
   
; redirect-gateway def1
route-method exe
route-delay 2

route 8.8.8.0 255.255.255.0 vpn_gateway
route 8.8.4.0 255.255.255.0 vpn_gateway
route 24.0.0.0 255.0.0.0 vpn_gateway
route 63.0.0.0 255.0.0.0 vpn_gateway
route 64.0.0.0 255.0.0.0 vpn_gateway
route 65.0.0.0 255.0.0.0 vpn_gateway
route 66.0.0.0 255.0.0.0 vpn_gateway
route 67.0.0.0 255.0.0.0 vpn_gateway
route 68.0.0.0 255.0.0.0 vpn_gateway
route 69.0.0.0 255.0.0.0 vpn_gateway
route 70.0.0.0 255.0.0.0 vpn_gateway
route 71.0.0.0 255.0.0.0 vpn_gateway
route 72.0.0.0 255.0.0.0 vpn_gateway
route 73.0.0.0 255.0.0.0 vpn_gateway
route 74.0.0.0 255.0.0.0 vpn_gateway
route 75.0.0.0 255.0.0.0 vpn_gateway
route 76.0.0.0 255.0.0.0 vpn_gateway
route 96.0.0.0 255.0.0.0 vpn_gateway
route 97.0.0.0 255.0.0.0 vpn_gateway
route 98.0.0.0 255.0.0.0 vpn_gateway
route 99.0.0.0 255.0.0.0 vpn_gateway
route 108.0.0.0 255.0.0.0 vpn_gateway
route 173.0.0.0 255.0.0.0 vpn_gateway
route 174.0.0.0 255.0.0.0 vpn_gateway
route 184.0.0.0 255.0.0.0 vpn_gateway
route 199.0.0.0 255.0.0.0 vpn_gateway
route 204.0.0.0 255.0.0.0 vpn_gateway
route 205.0.0.0 255.0.0.0 vpn_gateway
route 206.0.0.0 255.0.0.0 vpn_gateway
route 207.0.0.0 255.0.0.0 vpn_gateway
route 208.0.0.0 255.0.0.0 vpn_gateway
route 209.0.0.0 255.0.0.0 vpn_gateway
route 216.0.0.0 255.0.0.0 vpn_gateway
" > ${client}.conf

cp ${client}.conf ${client}.ovpn
