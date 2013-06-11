openvpn_install
===============

openvpn_install smartVPS

参考<a href="http://blog.csdn.net/vnity5/article/details/8189834" target="_blank">这里</a>。

以下均以root用户运行。

<h3>准备工作</h3>
注意：在安装openvpn之前，首先需要确认你VPS上的tun设备可用（很多OpenVZ VPS需要联系客服打开），否则openvpn无法启动
<code>cat /dev/net/tun</code>
<blockquote>cat: /dev/net/tun: File descriptor in bad state</blockquote>
只有这种显示的才是正确的，如果有
<blockquote>cat: /dev/net/tun: No such file or directory</blockquote>
或者
<blockquote>cat: /dev/net/tun: Permission denied</blockquote>
则TUN设备异常，无法安装OpenVPN。

<h3>安装必要的依赖</h3>
<code>yum install -y openssl openssl-devel automake pkgconfig iptables gcc lrzsz</code>

<h3>安装LZO</h3>
<code>wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.04.tar.gz
tar zxvf lzo-2.04.tar.gz
cd lzo-2.04/
./configure
make
make check
make install
cd ../</code>

<h3>安装OpenVPN</h3>
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

<h3>生成证书</h3>
<code>mkdir /etc/openvpn
cp -r easy-rsa /etc/openvpn/
cd /etc/openvpn/easy-rsa/2.0/
cp openssl-1.0.0.cnf openssl.cnf
source vars
./clean-all
./build-ca
</code>


<h3> 建立server key代码</h3>
<code>./build-key-server server</code>
注意在
<blockquote>A challenge password []:</blockquote>
时填上一个密码，例如12345678。

<h3>生成客户端Key</h3>
<code>./build-key client1 #client1可以改名 但要以下面步骤一致</code>
同样，注意在
<blockquote>A challenge password []:</blockquote>
时填上一个密码，例如12345678。
重复本步骤可以生成客户端证书key，但注意client1得不同。

<h3>生成Diffie Hellman参数</h3>
<code>$OPENSSL='openssl'
./build-dh</code>

<h3>将keys下的所有文件打包下载到本地</h3>
<code>tar -zcvf  keys.tar.gz keys
sz -be keys.tar.gz</code>


<h3>创建服务端配置文件</h3>
<code>vi /usr/local/etc/server.conf</code>
内容如下：
<blockquote>local 36.54.6.11 #请换成你自己的VPN的公网的ip地址
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

<h3>创建客户端配置文件</h3>
<code>vi /usr/local/etc/client1.conf</code>
内容如下：
<blockquote>client
dev tun
proto udp
  
remote 36.54.6.11 1194 #请换成自己VPN公网的ip，指定端口为1194
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


<h3>启动Openvpn</h3>

<code>/usr/local/sbin/openvpn --config /usr/local/etc/server.conf</code>

<h3>设置 OpenVPN 服务器开机启动</h3>
<code>vi /etc/rc.local</code>
加入：
<code>/usr/local/sbin/openvpn --config /usr/local/etc/server.conf > /dev/null 2>&1 &</code>

<h3>OpenVPN 访问外网的设置</h3>

打开路由 VPN连接成功后, 还需要设置路由, 才能透过VPN访问Internet. 在 VPS上添加路由，代码:
<code>iptables -t nat -A POSTROUTING -s 10.8.0.0/24  -j SNAT --to-source 36.54.3.39 #替换为自己的IP
/etc/init.d/iptables save
sysctl -w net.ipv4.ip_forward=1
/etc/init.d/iptables restart</code>

<h3>OpenVPN GUI For Windows 客户端安装</h3>
<ol>
	<li>下载OpenVPN GUI For Windows 客户端，请按照提示安装到本机. 将以上的client.conf拷贝到C:\Program Files\OpenVPN\config目录，重新命名为：client1.ovpn</li>
	<li>解压keys.tar.gz，把key/下的所有内容放到C:\Program Files\OpenVPN\config 目录. </li>
	<li>在WinXP PC上运行OpenVPN客户端软件，点击添加连接配置，选择本地文件导入，选中刚才保存的client.ovpn文件。</li>
</ol>

若有多个VPN客户端，则要添加配置文件文件，将在服务器上/usr/local/etc/client2.conf 的拷贝到客户端的C:\Program Files\OpenVPN\config目录下。

<h3>在iOS上使用OpenVPN</h3>
<ol>
	<li>下载应用openvpn；</li>
	<li>用itunes将以上keys/目录下的文件和client1.ovpn文件拷贝到openvpn应用的目录下；</li>
	<li>手机打开openvpn应用，导入刚才的配置；</li>
	<li>连接。</li>
</ol>

