openvpn_install
===============

openvpn_install smartVPS

�ο�<a href="http://blog.csdn.net/vnity5/article/details/8189834" target="_blank">����</a>��

���¾���root�û����С�

<h3>׼������</h3>
ע�⣺�ڰ�װopenvpn֮ǰ��������Ҫȷ����VPS�ϵ�tun�豸���ã��ܶ�OpenVZ VPS��Ҫ��ϵ�ͷ��򿪣�������openvpn�޷�����
<code>cat /dev/net/tun</code>
<blockquote>cat: /dev/net/tun: File descriptor in bad state</blockquote>
ֻ��������ʾ�Ĳ�����ȷ�ģ������
<blockquote>cat: /dev/net/tun: No such file or directory</blockquote>
����
<blockquote>cat: /dev/net/tun: Permission denied</blockquote>
��TUN�豸�쳣���޷���װOpenVPN��

<h3>��װ��Ҫ������</h3>
<code>yum install -y openssl openssl-devel automake pkgconfig iptables gcc lrzsz</code>

<h3>��װLZO</h3>
<code>wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.04.tar.gz
tar zxvf lzo-2.04.tar.gz
cd lzo-2.04/
./configure
make
make check
make install
cd ../</code>

<h3>��װOpenVPN</h3>
<code>wget http://swupdate.openvpn.net/community/releases/openvpn-2.1.4.tar.gz
tar zxvf openvpn-2.1.4.tar.gz
cd openvpn-2.1.4
./configure --with-lzo-headers=/usr/local/include \
 --with-lzo-lib=/usr/local/lib  \
--with-ssl-headers=/usr/include/openssl  \
--with-ssl-lib=/usr/lib
make
make install
cd ../</code>

<h3>����֤��</h3>
<code>mkdir /etc/openvpn
cp -r easy-rsa /etc/openvpn/
cd /etc/openvpn/easy-rsa/2.0/
cp openssl-1.0.0.cnf openssl.cnf
source vars
./clean-all
./build-ca
</code>


<h3> ����server key����</h3>
<code>./build-key-server server</code>
ע����
<blockquote>A challenge password []:</blockquote>
ʱ����һ�����룬����12345678��

<h3>���ɿͻ���Key</h3>
<code>./build-key client1 #client1���Ը��� ��Ҫ�����沽��һ��</code>
ͬ����ע����
<blockquote>A challenge password []:</blockquote>
ʱ����һ�����룬����12345678��
�ظ�������������ɿͻ���֤��key����ע��client1�ò�ͬ��

<h3>����Diffie Hellman����</h3>
<code>$OPENSSL='openssl'
./build-dh</code>

<h3>��keys�µ������ļ�������ص�����</h3>
<code>tar -zcvf  keys.tar.gz keys
sz -be keys.tar.gz</code>


<h3>��������������ļ�</h3>
<code>vi /usr/local/etc/server.conf</code>
�������£�
<blockquote>local 36.54.6.11 #�뻻�����Լ���VPN�Ĺ�����ip��ַ
port 1194
proto udp

dev tun
  
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
   
server 10.8.0.0 255.255.255.0
    
client-to-client
keepalive 10 120
         
comp-lzo
          
persist-key
persist-tun
status /etc/openvpn/easy-rsa/2.0/keys/openvpn-status.log
verb 4
           
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"</blockquote>

<h3>�����ͻ��������ļ�</h3>
<code>vi /usr/local/etc/client1.conf</code>
�������£�
<blockquote>client
dev tun
proto udp
  
remote 36.54.6.11 1194 #�뻻���Լ�VPN������ip��ָ���˿�Ϊ1194
persist-key
persist-tun
ca ca.crt
cert client1.crt         
key client1.key
ns-cert-type server
comp-lzo
verb 3
   
redirect-gateway def1
route-method exe
route-delay 2</blockquote>


<h3>����Openvpn</h3>

<code>/usr/local/sbin/openvpn --config /usr/local/etc/server.conf</code>

<h3>���� OpenVPN ��������������</h3>
<code>vi /etc/rc.local</code>
���룺
<code>/usr/local/sbin/openvpn --config /usr/local/etc/server.conf > /dev/null 2>&1 &</code>

<h3>OpenVPN ��������������</h3>

��·�� VPN���ӳɹ���, ����Ҫ����·��, ����͸��VPN����Internet. �� VPS�����·�ɣ�����:
<code>iptables -t nat -A POSTROUTING -s 10.8.0.0/24  -j SNAT --to-source 36.54.3.39 #�滻Ϊ�Լ���IP
/etc/init.d/iptables save
sysctl -w net.ipv4.ip_forward=1
/etc/init.d/iptables restart</code>

<h3>OpenVPN GUI For Windows �ͻ��˰�װ</h3>
<ol>
	<li>����OpenVPN GUI For Windows �ͻ��ˣ��밴����ʾ��װ������. �����ϵ�client.conf������C:\Program Files\OpenVPN\configĿ¼����������Ϊ��client1.ovpn</li>
	<li>��ѹkeys.tar.gz����key/�µ��������ݷŵ�C:\Program Files\OpenVPN\config Ŀ¼. </li>
	<li>��WinXP PC������OpenVPN�ͻ���������������������ã�ѡ�񱾵��ļ����룬ѡ�иղű����client.ovpn�ļ���</li>
</ol>

���ж��VPN�ͻ��ˣ���Ҫ��������ļ��ļ������ڷ�������/usr/local/etc/client2.conf �Ŀ������ͻ��˵�C:\Program Files\OpenVPN\configĿ¼�¡�

<h3>��iOS��ʹ��OpenVPN</h3>
<ol>
	<li>����Ӧ��openvpn��</li>
	<li>��itunes������keys/Ŀ¼�µ��ļ���client1.ovpn�ļ�������openvpnӦ�õ�Ŀ¼�£�</li>
	<li>�ֻ���openvpnӦ�ã�����ղŵ����ã�</li>
	<li>���ӡ�</li>
</ol>

