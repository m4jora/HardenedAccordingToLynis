#!/bin/bash
#go sudo
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
#create timestamp
declare stamp=$(date +%D[%T] | sed 's/\[/ \[/');
declare elog="/var/log/lynis-approved/error.log";
#make dir in /var/log
if [ ! -d "/var/log/lynis-approved" ]; then
mkdir /var/log/lynis-approved
fi
#run 'nolog' script, while logging stderr
#this makes  
printf "%s\n####################\nError Log Generated:" >> $elog
echo $stamp >> $elog
echo "####################" >> $elog
echo "" >> $elog
chmod +x lynis-approved-nolog.sh 
./lynis-approved-nolog.sh 3>&1 >&2 2>&3 3>&- | tee -a $elog
