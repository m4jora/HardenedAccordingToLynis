#!/bin/bash
#go sudo
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
#declarations
declare -i phase=1;
declare r="y";

#announce phase 
tout () {
clear
if [ $r == 'q' ]||[ $r == 'Q' ]; then
exit
fi
((phase++));
case $phase in
1)
echo "Phase 1: Upgrade Packages to Current Testing Versions"
;;
2)
echo "Phase 2: Install Essentials Security Packages"
;;
3)
echo "Phase 3: Harden /etc/login.defs Rules"
;;
4)
echo "Phase 4: Install/Enable sysstat Performance Monitoring Utils"
;;
5)
echo "Phase 5: Install/Enable acct for System Usage Info"
;;
6)
echo "Phase 6: Install/Enable resolvconf DNS Nameserver Manager"
;;
7)
echo "Phase 7: Allow gcc Execution by Root Only"
;;
8)
echo "Phase 8: Ensure CUPS Daemon Listens to localhost:631 Only"
;;
9)
echo "Phase 9: Install/Enable auditd & Auto-Generate audit.rules File"
;;
10)
echo "Phase 10: Install/Enable apache2 Security Modules & Fix Common Errors"
;;
11)
echo "Phase 11: Disable USB and FireWire Storage to Prevent Mount Attacks"
;;
12)
echo "Phase 12: Install/Enable arpwatch for Ethernet Protocol Monitoring"
;;
13)
echo "Phase 13: Create tmpfs on /tmp for Performance & Privacy"
;;
14)
echo "Phase 14: Subtley Threaten Unauthorized Remote Users"
;;
15)
echo "Phase 15: Install/Enable the clamav Anti-Virus Daemon"
;;
16)
echo "Phase 16: Limit File Permissions on Home Folder"
;;
17)
echo "Phase 17: Harden ssh Configuration by Editing /etc/ssh/sshd_config"
;;
18)
echo "Phase 18: Improve the sysctl Configuration with Included File"
;;
19)
echo "Phase 19: Restrict Compiling Privileges to Root"
;;
99)
echo "Phase 99: Purge Trash & Configs of Missing Apps"
;;
esac
code
}

#execute code 
code () {
echo ""
if [ $r == 'Q' ]||[ $r == 'q' ]; then
clear
exit
fi
read -p "Execute Phase ${phase}? [y/n or \'q\' to quit]: " r
if [ $r == 'q' ]||[ $r == 'Q' ]; then
clear
exit
fi

if [ $r == "Y" ] || [ $r == "y" ]; then
case $phase in
1)
sed -i 's/deb c/#deb c/' /etc/apt/sources.list
apt-get update -y && apt-get upgrade -y
apt-get install --reinstall libwacom-common -y
apt-get install dist-upgrade -y
apt-get autoremove -y
;;
2)
apt-get install -y apt-listbugs apt-show-versions bleachbit chkrootkit debsums fail2ban gufw john john-data lynis menu net-tools ssh-audit tiger tripwire ufw wireshark
apt-get autoremove -y
;;
3)
sed -i 's/UMASK		022/UMASK		027/' /etc/login.defs
sed -i 's/PASS_MAX_DAYS	99999/PASS_MAX_DAYS	90/' /etc/login.defs
sed -i 's/PASS_MIN_DAYS	0/PASS_MIN_DAYS	1/' /etc/login.defs
update-grub
;;
;;
4)
apt-get install sysstat -y
systemctl stop sysstat
sed -i '/ENABLED/s/false/true/' /etc/default/sysstat
systemctl enable sysstat
systemctl start sysstat
update-grub
echo "For Usage Examples: https://www.tecmint.com/sysstat-commands-to-monitor-linux/"
declare ff='n';
read -p "Launch Firefox? [y/n]: " ff
if [ $ff == 'y' ]||[ $ff == 'Y' ]; then
firefox https://www.tecmint.com/sysstat-commands-to-monitor-linux/
fi
;;
5)
apt-get install acct -y
/usr/sbin/accton on
systemctl enable acct
systemctl start acct
update-grub
echo "Command Info: \'ac -h\' & \'sa -h\'"
;;
6)
apt-get install resolvconf -y
declare rcd="/usr/lib/systemd/resolv.conf";
systemctl stop resolvconf
echo "nameserver 8.8.8.8" >> $rcd
echo "nameserver 8.8.4.4" >> $rcd
echo "nameserver 9.9.9.9" >> $rcd
echo "nameserver 149.112.112.112" >> $rcd
echo "nameserver 1.1.1.1" >> $rcd
echo "nameserver 1.0.0.1" >> $rcd
systemctl enable resolvconf
systemctl start resolvconf
update-grub
;;
7)
apt-get install gcc -y
printf "%s#\!/bin/bash\n" > hardgcc.sh
sed -i 's/\\//' hardgcc.sh
ls -la /usr/bin | grep '^-.*gcc' | sed 's/.* //g ; s/^/chownroot:root\/usr\/bin\//' | sed 's/ /\n/' >> hardgcc.sh
sed -i 's/chown/chown / ; s/:root/:root /' hardgcc.sh
chmod 777 hardgcc.sh
bash hardgcc.sh
sed -i 's/own root:root/mod 750/' hardgcc.sh
bash hardgcc.sh
rm hardgcc.sh
;;
8)
systemctl stop cups.service
sed -i 's/#Listen \/run/Listen \/run/' /etc/cups/cupsd.conf
sed -i 's/Listen \/run/#Listen \/run/' /etc/cups/cupsd.conf
systemctl enable cups.service
systemctl start cups.service
update-grub
;;
9)
apt-get install -y stunnel4 auditd postfix
systemctl stop auditd
declare AR='ar.incomplete';
declare STUNNEL_A='/usr/sbin/stunnel';
declare STUNNEL_B='/usr/bin/stunnel4';
[ -f "/etc/audisp/audisp-remote.conf" ] && sed -i '/audispconfig/s/#//' $AR
if [ -f $STUNNEL_A ]; then
sed -i '/stunnel/s/#//' $AR
else
if [ -f $STUNNEL_B ]; then
sed -i '/stunnel/s/sbin/bin/' $AR
sed -i '/stunnel/s/stunnel/stunnel4/' $AR
sed -i '/stunnel/s/#//' $AR
fi
fi
[ -f "/etc/gshadow" ] && sed -i '/etcgroup/s/#//' $AR
[ -f "/etc/shadow" ] && sed -i '/etcpasswd/s/#//' $AR
[ -f "/etc/security/opasswd" ] && sed -i '/opasswd/s/#//' $AR
[ -f "/etc/securetty" ] && sed -i '/securetty/s/#//' $AR
[ -f "/var/log/tallylog" ] && sed -i '/tallylog/s/#//' $AR
[ -d "/etc/init.d/"] && sed -i '/etc\/init\.d/s/#//' $AR
[ -d "/etc/init"] && sed -i '/etc\/init/s/#//' $AR
[ -f "/etc/inittab" ] && sed -i '/inittab/s/#//' $AR
[ -f "/etc/modprobe.conf" ] && sed -i '/modprobe/s/#//' $AR
[ -f "/etc/puppetlabs/puppet/ssl" ] && sed -i '/puppetlabs/s/#//' $AR
cp /etc/audit/rules.d/audit.rules /etc/audit/rules.d/audit.rules.backup
mv -f $AR /etc/audit/rules.d/audit.rules
systemctl enable auditd
systemctl start auditd
update-grub
;;
10)
apt-get install -y apache2 libapache2-mod-evasive libapache2-mod-security2 lynx
systemctl stop apache2
sed -i '1s/^/ServerName domaintitle\n/' /etc/apache2/apache2.conf
sed -i 's/#export APACHE_LYNX/export APACHE_LYNX/' /etc/apache2/envvars
systemctl enable apache2
systemctl start apache2
a2enmod evasive
a2enmod security2
apache2ctl restart
update-grub
;;
11)
echo "blacklist usb-storage" >> /etc/modprobe.d/jim_blacklist_usb.conf
echo "blacklist firewire-core" >> /etc/modprobe.d/jim_blacklist_firewire.conf
;;
12)
apt-get install arpalert arpwatch ieee-data 
systemctl enable arpwatch
systemctl start arpwatch
update-grub
;;
13)
mount -t tmpfs -o size=2048m tmpfs /tmp
echo "#mount /tmp as tmpfs" >> /etc/fstab
echo "tmpfs /tmp tmpfs nodev,nosuid,nodiratime,uid=50,gid=50,size=2048M 0 0" >> /etc/fstab
;;
14)
echo "If you are reading this message, you're in big trouble." >> /etc/issue
echo "If you are reading this message, you're in big trouble." >> /etc/issue.net
;;
15)
apt-get install clamav-base libmspack0 libtfm1 libclamav9 clamav-freshclam clamav clamav-daemon clamdscan libtext-csv-perl libjson-perl clamtk libclamunrar9 libclamunrar libcommon-sense-perl libencode-perl libtypes-serialiser-perl libjson-xs-perl libtext-csv-xs-perl
systemctl enable clamav-daemon
systemctl start clamav-daemon
;;
16)
chmod -R 750 /home/$SUDO_USER
;;
17)
declare SSHCONF="/etc/ssh/sshd_config";
if [ -f $SSHCONF ]; then
sed -i '/X11Forwarding/s/yes/no/' $SSHCONF
sed -i '/IgnoreRhosts/s/#//' $SSHCONF
sed -i '/UseDNS/s/#// ; /UseDNS/s/no/yes/' $SSHCONF
sed -i '/PermitEmpty/s/#//' $SSHCONF
sed -i '/MaxAuth/s/#// ; /MaxAuth/s/6/2/' $SSHCONF
sed -i 's/#PermitRootLogin .*/PermitRootLogin no/' $SSHCONF
sed -i '/AllowAgent/s/#// ; /AllowAgent/s/yes/no/' $SSHCONF
echo "Protocol 2" >> $SSHCONF
systemctl restart sshd
fi
;;
18)
sysctl -a > /tmp/sysctl-defaults.conf
cp sysctl.ideal /etc/sysctl.d/80-jim.conf
;;
19)
$(dpkg --list | grep compiler | grep -v '^ii  lib' | sed 's/ii  // ; s/ .*//' | sed 's/^/ \/usr\/bin\//g' | tr -s '\n' ' ' | sed 's/^/chown root:root/')
$(dpkg --list | grep compiler | grep -v '^ii  lib' | sed 's/ii  // ; s/ .*//' | sed 's/^/ \/usr\/bin\//g' | tr -s '\n' ' ' | sed 's/^/chmod 750/')
;;
99)
rm -rf /home/${SUDO_USER}/.local/share/Trash/*
apt-get purge $(apt list | grep '\[r' | sed 's/\/.*//' | tr -s '\n' ' ') -y
;;
esac
else
r="y";
clear
tout
fi
tout
}

#start
clear
echo "Warning: This utility is designed to harden security on a fresh install of Debian 12 (Bookworm). Some changes are reversible and some are not. Use at your own risk and a backup never hurt no one."
echo "Error Log: /var/log/jim-upgrade/error.log"
echo ""
read -p "Begin? [y/n]: " r
if [ $r == "Y" ] || [ $r == "y" ]; then
tout
else
clear
exit
fi
