#!/bin/sh

# Zawartosc skopiowac na pendrivea.
# Na zainstalowanym systemie z CD-QNX650SP1RT-boot-v1-13.iso
# wykonac polecenia:
# cd /fs/usb0/QNX_INSTALL
# sh qnx_setup.sh

echo "Instalacja rsync"
tar --directory=/usr --extract --file=rsync-3.0.8.tgz bin/rsync

echo "Instalacja rcv-net"
tar --directory=/usr/bin --strip-components=2 \
	--extract --file=odtworzStacje-20221204.tgz \
	odtworzStacje/exe_dbq6_64/rcv-net

echo "Instalacja our_keyP2"
tar --directory=/usr/bin --extract --file=QNX6-PRO-our_keyP2.tgz

echo "Instalacja PRO-2000"
sh 2022-07-6.5.17.9/QNX65-PRO-2000-RT-v6.5.17.9-20220706.sh

echo "Ustawienia sieci"
ifconfig wm0 172.30.8.25
hostname KOMPUTER_REZERWOWY
netmanager -w all
vim /etc/net.cfg

echo "Uruchomienie OpenSSH"
/opt/openssh/openssh-setup
/bin/chmod 0700 /root
passwd
echo "\n" >> /etc/rc.d/rc.local
echo "/etc/rc.d/rc.openssh" >> /etc/rc.d/rc.local
echo "/opt/openssh/sbin/sshd -f /opt/openssh/etc/sshd_config" \
	>> /etc/rc.d/rc.local
/etc/rc.d/rc.openssh
/opt/openssh/sbin/sshd -f /opt/openssh/etc/sshd_config

echo "Na komputerze rezerwowym uruchomic our_keyP2"
echo "Na QNAP-ie uruchomic ssh-copy-id root@<addr>"

