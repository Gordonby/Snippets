#!/bin/bash

sudo mkdir /mnt/$shareName
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/$storAcc.cred" ]; then
    sudo bash -c 'echo "username=$storAcc" >> /etc/smbcredentials/$storAcc.cred'
    sudo bash -c 'echo "password=fP3hgnGtTPUCcc5nd4VULKFGHZf/BCebzu2jG8rQJIqH/D+PYMvlq+G/oo/K5SlTOkaxwMWCCSzc+AStOSyb6g==" >> /etc/smbcredentials/$storAcc.cred'
fi
sudo chmod 600 /etc/smbcredentials/$storAcc.cred

sudo bash -c 'echo "//$storAcc.file.core.windows.net/$shareName /mnt/$shareName cifs nofail,credentials=/etc/smbcredentials/$storAcc.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //$storAcc.file.core.windows.net/$shareName /mnt/$shareName -o credentials=/etc/smbcredentials/$storAcc.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30

#Now that we've mounted the file share, we can copy the files from the source to the destination
sudo cp -r /mnt/$shareName/$sourceFolder /mnt/$shareName/data/CLI2