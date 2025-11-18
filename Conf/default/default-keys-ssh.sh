#! /bin/bash

#Authorize password authentication.
sudo echo -e "# Added by DietPi:\nPasswordAuthentication yes\nPermitRootLogin no" >> dietpi.conf
sudo mv dietpi.conf /etc/ssh/sshd_config.d
sudo chmod 644 /etc/ssh/sshd_config.d/dietpi.conf
sudo service sshd restart

#Create folders to put the private keys.
sudo mkdir /mnt/Cloud/Public/Keys_SSH

#Go to .ssh folder to create SSH Keys.
cd ~/.ssh

ARS=( "$@" )

#Do it while have a Device.
for (( i=4; i<$#; i++));
do

    #Device.
    a=${ARS[i]}

    #Generate a Device SSH key.
    sudo ssh-keygen -f "$a($3)" -P ""

    #Copy the Device SSH key to admin user.
    sudo sshpass -p "$(echo "$4")" ssh-copy-id -i "$a($3).pub" "$3@$1$2"

    #Change Device SSH key permissions.
    sudo chmod 777 "$a($3)"

    #Move Device SSH Key to /mnt/Cloud/Keys_SSH and easily export with Dietpi-Dashboard or Samba.
    sudo mv "$a($3)" /mnt/Cloud/Public/Keys_SSH

done

#Deny password authentication.
sudo echo -e "# Added by DietPi:\nPasswordAuthentication no\nPermitRootLogin no" >> dietpi.conf
sudo mv dietpi.conf /etc/ssh/sshd_config.d
sudo chmod 644 /etc/ssh/sshd_config.d/dietpi.conf
sudo service sshd restart

#Give right permissions to files and folder
sudo chmod -R 777 /mnt/Cloud/Public/Keys_SSH