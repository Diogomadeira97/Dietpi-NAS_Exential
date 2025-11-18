#! /bin/bash

#Update and upgrade pkgs
sudo apt-get update -y
sudo apt-get upgrade -y

#Update Dietpi
sudo /boot/dietpi/dietpi-update

#Update Fail2Ban, Dietpi-Dashboard, PiVPN(Wireguard), Unbound, AdGuard_Home, Samba_server, Kavita, Nginx, LEMP, Docker, Docker_Compose, Portainer, Home-Assistant, Homer, Certbot, Samba Client and Nextcloud.
sudo /boot/dietpi/dietpi-software reinstall 73 200 117 182 126 96 212 85 79 134 162 185 157 1 114 92
