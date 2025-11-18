#! /bin/bash

#Create folders to put the private keys.
sudo mkdir /mnt/Cloud/Public/Keys_VPN

ARS=( "$@" )

#Do it while have a Device.
for (( i=1; i<$#; i++)); 
do

    #Device.
    a=${ARS[i]}

    #Create a Device Wireguard Key.
    (echo "";) | sudo pivpn add -n $a

done

#Move Device Wireguard Key to /mnt/Cloud/Keys_VPN and easily export with Dietpi-Dashboard or Samba.
sudo chmod 777 /home/$1/configs/*
sudo mv /home/$1/configs/* /mnt/Cloud/Public/Keys_VPN
sudo rm -rf /home/$1/configs