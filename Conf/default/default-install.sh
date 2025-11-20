#! /bin/bash

passwd(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;}
 
ARS=( "$@" )

VARIABLES=()
USERS=()
DEVICES=()

i=-1

until [ ${ARS[i]} = "." ]
do

        if [ ${ARS[i]} != "." ]; then
                VARIABLES+=(${ARS[i]})
                ((i++))
        fi

done

((i++))

until [ ${ARS[i]} = "." ]
do

        if [ ${ARS[i]} != "." ]; then
                USERS+=(${ARS[i]})
                ((i++))
        fi

done

((i++))

for (( $i; i<=$#; i++));
do

    DEVICES+=(${ARS[i]})

done

#dietpi-config
/boot/dietpi/dietpi-config

#dietpi-drive_manager
/boot/dietpi/dietpi-drive_manager

#dietpi-sync
/boot/dietpi/dietpi-sync

#dietpi-backup
/boot/dietpi/dietpi-backup

#Create directory and move Dietpi-NAS_Exential folder.
cd ../../../
mkdir /mnt/Cloud/Data
mv Dietpi-NAS_Exential /mnt/Cloud/Data

#Go to Cloud and create default folders.
cd /mnt/Cloud
mkdir Data/Commands Data/Docker Data/Docker/immich-app Data/Docker/vscodium Data/Docker/gimp Data/Docker/stirling Data/Docker/passbolt Data/Docker/esphome Public Public/Docs Public/Midias Public/Passwords Users

#Default variables.
SERVERNAME=${VARIABLES[1]}
mkdir $SERVERNAME $SERVERNAME/Midias $SERVERNAME/Docs
echo -e "#Default variables.\n" >> PASSWD_$SERVERNAME.txt
echo -e "       • SERVERNAME: $SERVERNAME\n" >> PASSWD_$SERVERNAME.txt
DIETPIPW=$(passwd)
echo -e "       • DIETPIPW: $DIETPIPW\n" >> PASSWD_$SERVERNAME.txt
DBIMMICHPW=$(passwd)
echo -e "       • DBIMMICHPW: $DBIMMICHPW\n" >> PASSWD_$SERVERNAME.txt
DBOFFICEPW=$(passwd)
echo -e "       • DBOFFICEPW: $DBOFFICEPW\n" >> PASSWD_$SERVERNAME.txt
DBPASSBOLTPW=$(passwd)
echo -e "       • DBPASSBOLTPW: $DBPASSBOLTPW\n" >> PASSWD_$SERVERNAME.txt

#Default Users.
echo -e "#Default Users.\n" >> PASSWD_$SERVERNAME.txt
ADMIN=${VARIABLES[2]}
ADMINPW=$(passwd)
echo -e "       • $ADMIN: $ADMINPW\n" >> PASSWD_$SERVERNAME.txt
ADMINSMBPW=$(passwd)
echo -e "       • $ADMIN(smb): $ADMINSMBPW\n" >> PASSWD_$SERVERNAME.txt
GUEST=${VARIABLES[3]}
GUESTPW=$(passwd)
echo -e "       • $GUEST: $GUESTPW\n" >> PASSWD_$SERVERNAME.txt
GUESTSMBPW=$(passwd)
echo -e "       • $GUEST(smb): $GUESTSMBPW\n\n" >> PASSWD_$SERVERNAME.txt
ADMINESPHOME=$(passwd)
echo -e "       • admin-esphome: $ADMINESPHOME\n\n" >> PASSWD_$SERVERNAME.txt

#Default Server.
echo -e "#Default Server.\n" >> PASSWD_$SERVERNAME.txt
DOMAIN=${VARIABLES[4]}
echo -e "       • DOMAIN: $DOMAIN\n" >> PASSWD_$SERVERNAME.txt
TPDOMAIN=${VARIABLES[5]}
echo -e "       • TPDOMAIN: $TPDOMAIN\n" >> PASSWD_$SERVERNAME.txt
IP=${VARIABLES[6]}
echo -e "       • IP: $IP\n" >> PASSWD_$SERVERNAME.txt
CLOUDFLARETOKEN=${VARIABLES[7]}
echo -e "       • CLOUDFLARETOKEN: $CLOUDFLARETOKEN\n" >> PASSWD_$SERVERNAME.txt
EMAIL=${VARIABLES[8]}
echo -e "       • EMAIL: $EMAIL\n" >> PASSWD_$SERVERNAME.txt

#Move passwords with right permissions to Public.
mv PASSWD_$SERVERNAME.txt /mnt/Cloud/Public/Passwords
sudo chmod -R 777 /mnt/Cloud/Public/Passwords

#Define Umask.
umask 0022

#Add default users.
adduser --quiet --disabled-password --shell /bin/bash --home /home/"$ADMIN" --gecos "User" "$ADMIN"
adduser --quiet --disabled-password --shell /bin/bash --home /home/"$GUEST" --gecos "User" "$GUEST"
echo "$ADMIN:"$(echo "$ADMINPW")"" | chpasswd
echo "$GUEST:"$(echo "$GUESTPW")"" | chpasswd

#Install Python 3.
/boot/dietpi/dietpi-software install 130

#Install Fail2Ban, Dietpi-Dashboard, PiVPN(Wireguard), Unbound, AdGuard_Home, Samba_server, Kavita, Nginx, LEMP, Docker, Docker_Compose, Portainer and Home-Assistant.
/boot/dietpi/dietpi-software install 73 200 117 182 126 96 212 85 79 134 162 185 157

#Add default users Samba password.
(echo "$(echo "$ADMINSMBPW")"; echo "$(echo "$ADMINSMBPW")") | smbpasswd -a -s $ADMIN
(echo "$(echo "$GUESTSMBPW")"; echo "$(echo "$GUESTSMBPW")") | smbpasswd -a -s $GUEST

#Exclude dietpi user from Samba.
pdbedit -x dietpi

#Create group names.
CLOUD="$(echo $SERVERNAME'_Cloud' )"
BAK="$(echo $SERVERNAME'_BAK' )"

#Add default groups.
groupadd $CLOUD
groupadd $BAK
groupadd $SERVERNAME

#Add default users to default groups.
usermod -a -G $CLOUD "$ADMIN"
usermod -a -G $CLOUD "$GUEST"
usermod -a -G $SERVERNAME "$ADMIN"
usermod -a -G $BAK "$ADMIN"

#Turn admin in SU without password.
echo -e "$ADMIN ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#Go to Samba folder.
cd /mnt/Cloud/Data/Dietpi-NAS_Exential/Conf/Samba

#Create default Samba share folders.
echo -e "        guest account = $GUEST" >> smb.conf
cat smb_temp.conf >> smb.conf
echo -e "        valid users = $ADMIN" >> smb.conf
echo -e "\n\n#User $SERVERNAME\n\n[$SERVERNAME]\n        comment = $SERVERNAME\n        path = /mnt/Cloud/$SERVERNAME\n        valid users = @$SERVERNAME" >> smb.conf
mv smb.conf /etc/samba/smb.conf
chmod 644 /etc/samba/smb.conf
systemctl restart smbd nmbd

#Change Dietpi-Dashboard password and terminal user to admin.
hash=$(echo -n "$(echo "$DIETPIPW")" | sha512sum | mawk '{print $1}')
secret=$(openssl rand -hex 32)
echo -e "pass = true" >> config.toml
echo -e 'hash="'$hash'"' >> config.toml
echo -e 'secret="'$secret'"' >> config.toml
echo -e 'terminal_user = "'$ADMIN'"' >> config.toml
mv config.toml /opt/dietpi-dashboard/
chmod 644 /opt/dietpi-dashboard/config.toml
unset -v hash secret

#Restart Dietpi-Dashboard.
systemctl restart dietpi-dashboard-frontend dietpi-dashboard-backend

#Go to default folder.
cd /mnt/Cloud/Data/Dietpi-NAS_Exential/Conf/default

#Use 'sudo bash /mnt/Cloud/Data/Commands/default.sh' and reconfig folders permissions to default.
mv default.sh /mnt/Cloud/Data/Commands

#Use 'sudo bash /mnt/Cloud/Data/Commands/default-user.sh' to add some users.
mv default-user.sh /mnt/Cloud/Data/Commands

#Use 'sudo bash /mnt/Cloud/Data/Commands/default-keys-ssh.sh' to add some ssh keys.
mv default-keys-ssh.sh /mnt/Cloud/Data/Commands

#Use 'sudo bash /mnt/Cloud/Data/Commands/default-keys-vpn.sh' to add some vpn keys.
mv default-keys-vpn.sh /mnt/Cloud/Data/Commands

#Use 'sudo bash /mnt/Cloud/Data/Commands/subdomain.sh' to add some subdomain.
mv subdomain.sh /mnt/Cloud/Data/Commands

#Use 'sudo bash /mnt/Cloud/Data/Commands/subdomain.sh' to add some subdomain.
mv subdomain-docker.sh /mnt/Cloud/Data/Commands

#Use 'sudo bash /mnt/Cloud/Data/Commands/subpath.sh' to add some subpath.
mv subpath.sh /mnt/Cloud/Data/Commands

#Use 'sudo bash /mnt/Cloud/Data/Commands/update_server.sh' to update server (without docker).
mv update_server.sh /mnt/Cloud/Data/Commands

#Use 'sudo bash /mnt/Cloud/Data/Commands/update_server.sh' to update server (only docker).
mv update_server_docker.sh /mnt/Cloud/Data/Commands

#Create iptables_custom.sh.
echo -e "#! /bin/bash" >> iptables_custom.sh

#Use 'sudo bash /mnt/Cloud/Data/Commands/iptables_custom.sh' to add iptables.
mv iptables_custom.sh /mnt/Cloud/Data/Commands

#Create immich_uploads.sh.
echo -e "#! /bin/bash\nsudo 7z a /mnt/Cloud/Users/\$1/Midias/Midias-Anuais/immich-uploads.7z /mnt/Cloud/Data/Docker/immich-app/immich-files/library/\$1" >> immich_uploads.sh

#Use 'sudo bash /mnt/Cloud/Data/Commands/immich_uploads.sh (USER)' to create a backup of uploads.
mv immich_uploads.sh /mnt/Cloud/Data/Commands

#Create reboot.sh.
echo -e "#! /bin/bash" >> reboot.sh

#Use 'sudo nano /mnt/Cloud/Data/Commands/reboot.sh' to add custom reboot.
mv reboot.sh /mnt/Cloud/Data/Commands

#Create crontab to custom iptables and reboot.
echo -e "@reboot sleep 10 && /mnt/Cloud/Data/Commands/iptables_custom.sh" >> crontab
echo -e "@reboot sleep 20 && /mnt/Cloud/Data/Commands/reboot.sh" >> crontab
crontab crontab
rm crontab

#Install Access Control List.
apt install acl sshpass -y

#Install zip
apt-get install p7zip-full -y

#This code is to fix the reboot error message.
systemctl unmask systemd-logind
apt install dbus -y
systemctl start dbus systemd-logind

#Go to mount drives and delete unnecessary files.
cd /mnt
rm -rf ftp_client nfs_client samba

#Set Cloud default permissions.
setfacl -R -b Cloud
chmod -R 775 Cloud
chown -R $ADMIN:$CLOUD Cloud
setfacl -R -d -m u::rwx Cloud
setfacl -R -d -m g::rwx Cloud
setfacl -R -d -m o::r-x Cloud
chmod -R g+s Cloud

#Set BAK_Cloud default permissions.
chmod 750 BAK_Cloud
chown $ADMIN:$BAK BAK_Cloud
chmod g+s BAK_Cloud

#Set Public default permissions.
cd Cloud
setfacl -R -m user:dietpi:rwx Public/Docs
setfacl -R -m user:dietpi:rwx Public/Midias

#Set Data default permissions.
chown -R $ADMIN:$SERVERNAME Data
chmod -R 750 Data
setfacl -R -d -m g::r-x Data
setfacl -R -d -m o::--- Data
setfacl -m user:www-data:rwx Data

#Create and set default owner to user folders.
cd $SERVERNAME
mkdir Midias/Midias-Anuais Midias/Livros
chown -R $ADMIN:$SERVERNAME ../$SERVERNAME

#Set Docs default permissions.
chmod -R 770 Docs
setfacl -R -d -m o::--- Docs

#Go to Midias, create default folders and set default permissions.
cd Midias
chmod -R 770 Midias-Anuais
setfacl -R -d -m o::--- Midias-Anuais

#Install tools.
bash /mnt/Cloud/Data/Dietpi-NAS_Exential/Conf/default/default-tools.sh $DBIMMICHPW $DBOFFICEPW $DBPASSBOLTPW $DOMAIN $TPDOMAIN $SERVERNAME $ADMIN $ADMINESPHOME

#Install Certbot and Homer to set server default configs.
bash /mnt/Cloud/Data/Dietpi-NAS_Exential/Conf/default/default-server.sh $DOMAIN $TPDOMAIN $IP $CLOUDFLARETOKEN $SERVERNAME $EMAIL

#Add Users.
bash /mnt/Cloud/Data/Commands/default-user.sh $SERVERNAME ${USERS[@]}

#Add Domain to known_hosts.
ssh-keyscan -H $DOMAIN$TPDOMAIN >> ~/.ssh/known_hosts

#Add Devices (SSH).
bash /mnt/Cloud/Data/Commands/default-keys-ssh.sh $DOMAIN $TPDOMAIN $ADMIN $ADMINPW ${DEVICES[@]}

#Add Devices (VPN).
bash /mnt/Cloud/Data/Commands/default-keys-vpn.sh $ADMIN ${DEVICES[@]}

#Delete the installation folder.
rm -rf /mnt/Cloud/Data/Dietpi-NAS_Exential

#Reboot the system and use SSH key to login with admin.
reboot
