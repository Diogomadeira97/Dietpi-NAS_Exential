#! /bin/bash

#Go to mount drives.
cd /mnt

#Set Cloud default permissions.
setfacl -R -b Cloud
chmod -R 775 Cloud
chown -R $2:$1_Cloud Cloud
setfacl -R -d -m u::rwx Cloud
setfacl -R -d -m g::rwx Cloud
setfacl -R -d -m o::r-x Cloud
chmod -R g+s Cloud

#Set BAK_Cloud default permissions.
chmod 750 BAK_Cloud
chown $2:$1_BAK BAK_Cloud
setfacl -d -m u::rwx BAK_Cloud
setfacl -d -m g::r-x BAK_Cloud
setfacl -d -m o::--- BAK_Cloud
chmod g+s Cloud BAK_Cloud

#Set Data default permissions.
cd Cloud
chmod -R 750 Data
setfacl -R -d -m u::rwx Data
setfacl -R -d -m g::r-x Data
setfacl -R -d -m o::--- Data

#Turn $2 the owner of Folder.
chown -R $2:$1_Cloud Data/Commands

#Restart Samba_server.
service samba restart