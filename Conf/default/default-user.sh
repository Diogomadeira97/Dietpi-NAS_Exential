#! /bin/bash

passwd(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;}

ARS=( "$@" )

#Do it while have a User.
for (( i=1; i<$#; i++));
do

    #User.
    USER=${ARS[i]}
    echo -e "#User $USER.\n" >> PASSWD_$USER.txt
    USERPW=$(passwd)
    echo -e "$(echo "       • $USER: $USERPW\n")" >> PASSWD_$USER.txt
    USERSMBPW=$(passwd)
    echo -e "$(echo "       • $USER(smb): $USERSMBPW")" >> PASSWD_$USER.txt
    
    #Move passwords with right permissions to Public.
    sudo chmod 777 PASSWD_$USER.txt
    sudo mv PASSWD_$USER.txt /mnt/Cloud/Public/Passwords

    #Add user.
    sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/$USER --gecos "User" "$USER"
    sudo echo "$USER:"$(echo "$USERPW")"" | chpasswd

    #Add Samba password.
    (echo "$(echo "$USERSMBPW")"; echo "$(echo "$USERSMBPW")") | sudo smbpasswd -a -s $USER

    #Create group names.
    CLOUD="$(echo $1'_Cloud' )"

    #Put user in the default group.
    sudo usermod -a -G $CLOUD "$USER"
    sudo usermod -a -G $1 "$USER"

    #Go to Users folder and create default folders to the user.
    cd /mnt/Cloud/Users
    sudo mkdir $USER $USER/Docs $USER/Midias

    #Create and set default owner to user folders.
    cd $USER
    sudo mkdir Midias/Midias-Anuais Midias/Livros
    sudo chown -R $USER:$CLOUD ../$USER

    #Set Docs default permissions.
    sudo chown -R $USER:$USER Docs
    sudo chmod -R 770 Docs
    sudo setfacl -R -d -m o::--- Docs

    #Go to Midias, create default folders and set default permissions.
    cd Midias
    sudo chmod -R 770 Midias-Anuais
    sudo chown -R $USER:$USER Midias-Anuais
    sudo setfacl -R -d -m o::--- Midias-Anuais

    #Add Samba share folders to the user.
    sudo cat /etc/samba/smb.conf >> smb.conf
    sudo echo -e "\n\n#User $USER\n\n[$USER]\n        comment = $USER\n        path = /mnt/Cloud/Users/$USER\n        valid users = $USER" >> smb.conf
    sudo chown root:root smb.conf
    sudo chmod 644 smb.conf
    sudo mv smb.conf /etc/samba/smb.conf
    sudo service samba restart

    #Add user folders to immich.
    cd /mnt/Cloud/Data/Docker/immich-app
    sudo echo -e "      - /mnt/Cloud/Users/$USER/Midias/Midias-Anuais:/mnt/Cloud/Users/$USER/Midias/Midias-Anuais" >> docker-compose.yml
    sudo docker compose up -d

done
