# Dietpi NAS


## Description:

Collection of scripts to perform a complete installation of a NAS-Server running Dietpi. The goal is to have a home lab that runs very lightly and very safely, so the focus of this configuration is on:

• Permissions.

• Private Keys.

• Encryption.

• Variety of passwords.

• Secure Remote Access.

• Virtual Private Networking (VPN).

• Network Masking.

In addition to security, another fundamental objective is to be an environment where users have full control of their files, so services that use third-party servers are limited to cloudflare, to perform DNS pointing, and a DDNS server chosen by the user to point the Dynamic Public IP ([see recommendations](#DDNS)). All other services running are self-hosted and free, so you don't need to pay nothing or subscribe to any paid subscription. The services running so far are:

• [Fail2Ban](https://dietpi.com/docs/software/system_security/#fail2ban).

• [OpendSSH](https://dietpi.com/docs/software/ssh/#openssh).

• [Dietpi-Dashboard](https://dietpi.com/docs/software/system_stats/#dietpi-dashboard).

• [Samba Server](https://dietpi.com/docs/software/file_servers/#samba).

• [Docker](https://dietpi.com/docs/software/programming/#docker).

• [Docker_Compose](https://dietpi.com/docs/software/programming/#docker-compose).

• [Portainer](https://dietpi.com/docs/software/programming/#portainer).

• [Transmission](https://dietpi.com/docs/software/bittorrent/#transmission).

• [Sonarr](https://dietpi.com/docs/software/bittorrent/#sonarr).

• [Radarr](https://dietpi.com/docs/software/bittorrent/#radarr).

• [Prowlarr](https://dietpi.com/docs/software/bittorrent/#prowlarr).

• [Readarr](https://dietpi.com/docs/software/bittorrent/#readarr).

• [Bazarr](https://dietpi.com/docs/software/bittorrent/#bazarr).

• [Jellyfin](https://dietpi.com/docs/software/media/#jellyfin).

• [Kavita](https://dietpi.com/docs/software/media/#kavita).

• [AdGuard Home](https://dietpi.com/docs/software/dns_servers/#adguard-home).

• [Unbound](https://dietpi.com/docs/software/dns_servers/#unbound).

• [PiVPN(Wireguard)](https://dietpi.com/docs/software/vpn/#pivpn).

• [Homer](https://dietpi.com/docs/software/system_stats/#homer).

• [Nginx Web Server](https://dietpi.com/docs/software/webserver_stack/#nginx).

• [Certbot Let’s Encrypt](https://dietpi.com/docs/software/system_security/#lets-encrypt).

• [Flaresolver](https://github.com/FlareSolverr/FlareSolverr).

• [Immich](https://immich.app/).

• [Home assistant](https://dietpi.com/docs/software/home_automation/#home-assistant).

Last but not least, the installation was thought out to be practical, so that people with little knowledge can install without worrying about the security of their network. In this sense, it is possible to use some <a name="scripts">scripts</a> in the post-installation located in /mnt/Cloud/Data/Commands:

• [default.sh](Conf/default/default.sh).

> Reconfigure folders to default permissions and default owners.

	bash /mnt/Cloud/Data/Commands/default.sh <ADMIN> <SERVERNAME>

• [default-user.sh](Conf/default/default-user.sh).

> Create Users with the default configuration to folders, permissions, groups, and Samba Share.

	bash /mnt/Cloud/Data/Commands/default-user.sh <$SERVERNAME> <USER1> ... <USERx>

• [default-keys-ssh.sh](Conf/default/default-keys-ssh.sh).

> Create SSH Private keys to multiple devices (Login on root).

	bash /mnt/Cloud/Data/Commands/default-keys-ssh.sh <DOMAIN> <TPDOMAIN> <USER> <USERPW> <DEVICE1> ... <DEVICEx>

• [default-keys-vpn.sh](Conf/default/default-keys-vpn.sh).

> Create VPN Private keys to multiple devices.

	bash /mnt/Cloud/Data/Commands/default-keys-vpn.sh <ADMIN> <DEVICE1> ... <DEVICEx>

• [subdomain.sh](Conf/default/subdomain.sh).

> Create subdomain to a service in Nginx and Homer.

	bash /mnt/Cloud/Data/Commands/subdomain.sh <DOMAIN> <TPDOMAIN> <SERVICE> <PORT> <IP>

• [subpath.sh](Conf/default/subpath.sh).

> Create subpath to a service in Nginx and Homer.

	bash /mnt/Cloud/Data/Commands/subpath.sh <DOMAIN> <TPDOMAIN> <SERVICE>


## Index:

• [Description](#Description)

• [Notes](#Notes)

• [Requirements](#Requirements)

• [Recommendations](#Recommendations)

• [Tips](#Tips)

• [Installation](#Installation)

> • [First Steps](#First-Steps)

> • [Commands](#Commands)

• [Services Configuration](#Services-Configuration)

> • [Dietpi-Dashboard](#Dietpi-Dashboar)

> • [AdGuard Home](#AdGuard-Home)

> • [Fail2Ban](#Fail2Ban)

> • [Transmission and Arrs](#Transmission-and-Arrs)

> • [Jellyfin and Kavita](#Jellyfin-and-Kavita)

> • [Immich](#Immich)

> • [PiVPN](#PiVPN)

> • [Nginx - Certbot](#Nginx-Certbot)

• [Devices Configuration](#Devices-Configuration)

> • [On Windows](#On-Windows)

> • [On Termux](#On-Termux)


## Notes:

The remote used of this installation is designed to be only with a VPN, so the only port forwarding that is being performed is for the Wireguard (UDP). It is not recommended to use this installation to expose your public IP directly on the Internet. If you want to do it, is at your own risk.


## Requirements:

• Domain with DNS pointing to Cloudflare.

• Public IPv4 and IPv6 (Static or Dynamic).

• Prefix delegation and SLAAC+RDNSS (IPv6) on router.

• Two Storage Devices.

• A support device for Dietpi. Check available devices [here](https://dietpi.com/).


## Recommendations:

• Put ONT or ONU in Bridge and connect router with <a name="PPPoE">PPPoE</a>. This will greatly increase the speed and stability of the network by preventing a double NAT. If You have a router that is also an ONT or ONU, you can skip that part.

• It is recommended that your public IP IPv4 be dynamic, so that there is one more layer of network protection. However, it is necessary to use a <a name="DDNS">DDNS</a> service such as [Duck DNS](https://www.duckdns.org/) or [No IP](https://www.noip.com/) for example.

• A router with some kind of network protection.

• Connect the server only on <a name="LAN">LAN</a> and purge all WiFi related APT packages. This will improve network stability and device security.

• The primary storage device should preferably be an SSD, and the backup one HD.

• Some kind of cooling on the device running the server.

• Offsite backups at least every month.

• This installation will create SSH Private Keys only to Admin user, so choose enabled devices to Super User Login. To create others VPN and SSH keys, use the commands mentioned [here](#scripts). Protect the Keys very well because with they anyone can access your server.



## Tips:

•  The private keys (Samba Server and Wireguard) and the files with generated passwords for server and users  will be create on /mnt/Cloud/Public/Keys_SSH, /mnt/Cloud/Public/Keys_VPN and /mnt/Cloud/Public/Passwords consecutively, use Samba or Diet-Dashboard to easily export. Use one key per device and store them very well, you don't want them to fall into the wrong hands.


## Pre-Installation:

• Put router in Dynamic DHCP.

• On router, enable IPv6 with IP auto, prefix delegation and SLAAC+RDNSS (If is set [PPPoE](#PPPoE) on IPv4 put here too).

• Create a port <a name="forwarding">forwarding</a> (UDP), using the IPv4 and IPv6 of the server, with the port you chose (default is 51820).

• If the [DDNS](#DDNS) recommendation is choose, create a domain to Public IPv4.

• Create a 'A' record to the domain and a 'A' record to the wildcard, point both to your server private ip.

	ifconfig

• Before installing, create your variables using the [Models](Conf/Models) template files.

• On Cloudflare create a token and put IPv4 and IPv6 to filter. If necessary, before [Commands](#Commands), use this command to check eth0 IPs:

• Save the token and put on [Models](Conf/Models).


## Installation:


### First Steps:

• Download the last image of Dietpi to your device [here](https://dietpi.com/).

• If necessary, use [Rufus](https://rufus.ie/) to create a bootable USB drive.

Do the first login and follow the instructions.


#### Login:

> login: root

> Password: dietpi

• Change Global and root Password.

• When ask about UART, mark 'no'.


#### dietpi-software:

• Change Dropbear to OpenSSH.

• Select 0: Opt OUT and purge uploaded data mark no.

• Install.

#### Commands:

	CLOUDFLARE="$(echo '<TOKEN>')"
	VARIABLES=('<SERVER_NAME>' '<ADMIN_NAME>' '<GUEST_NAME>' '<DOMAIN>' '<TP_DOMAIN>' '<IP>' $CLOUDFLARE '<EMAIL>')
	USERS=('<USER1>' ... '<USERx>')
	DEVICES=('<DEVICE1>' ... '<DEVICEx>')

	apt install git -y
    git clone https://github.com/Diogomadeira97/Dietpi-NAS
	cd Dietpi-NAS/Conf/default
    chmod +x ./*
	bash default-install.sh ${VARIABLES[@]} . ${USERS[@]} . ${DEVICES[@]}
	unset -v CLODUFLRAE VARIABLES USERS DEVICES


#### dietpi-config:

• Change timezone on 'Language/Regional Options'.

• Change host name on 'Security Options'.
	
• Change the networking to **STATIC** and enable IPv6 on 'Network Options: Adapters'.

• When ask about purge all WiFi related APT packages, mark 'yes', as stated in the [LAN](#LAN) recommendation.

• Exit.

#### dietpi-drive_manager:

• Mount faster drive to /mnt/Cloud. 

• Mount the other drive to /mnt/BAK_Cloud.

• Do benchmark to test if necessary.

• Exit.

#### dietpi-sync:

• Change Source Location to /mnt/Cloud.

• Change Target Location to /mnt/BAK_Cloud.

• Turn on Delete Mode.

• Turn on Daily Sync.

• Exit.

#### dietpi-backup:

• Change the location path to /mnt/Cloud/Data/dietpi-backup.

• Turn on Daily Backup and Space Check.

• Change the quantity to 3.

• Exit.

#### Dietpi-Dashboard:
 	
• Chose Stable on Dietpi-Dashboard.

• Chose no to "only backend".


#### PiVPN:

• Chose admin to user.

• Set wireguard and use the default options.

• Choose a port based on the (forwarding)[#forwarding] you made in the pre-installation.

• Set the DNS provider to "PiVPN-is-local-DNS".

• If the [DDNS](#DDNS) recommendation is being made, chose DDNS and put your domain.


### Services Configuration:


#### Portainer

• If you do not log in and complete the initial setup within 5 minutes the Portainer service within the container stops. This is a security measure to prevent a malicious user taking over a fresh Portainer installation. Read more [here](https://portal.portainer.io/knowledge/your-portainer-instance-has-timed-out-for-security-purposes).

• You resolve this by running:

	sudo docker stop portainer
	sudo docker start portainer

• After this, do the initial setup on web UI in less then 5 minutes.


#### Passbolt

• Create your first admin user with this command:

	cd /mnt/Cloud/Data/Docker/passbolt
	sudo docker compose -f docker-compose-ce.yaml exec passbolt su -m -c "/usr/share/php/passbolt/bin/cake passbolt register_user -u <EMAIL> -f Admin -l User -r admin" -s /bin/sh www-data

• This registration command will return a single use url required to continue the web browser setup and finish the registration.

• After registration, configure SMTP on Passbolt. Then edit "docker-compose-ce.yaml" and change the line "PASSBOLT_SECURITY_SMTP_SETTINGS_ENDPOINTS_DISABLED" to "true" with this command:

	cd /mnt/Cloud/Data/Docker/passbolt
	sudo nano docker-compose-ce.yaml
	sudo docker compose -f docker-compose-ce.yaml up -d

#### Nextcloud:

• Login on web UI with: 

> Username: admin

> Password: Global.

• Change default user and password.

• Add Onlyoffice on apps and do the conection with this url:

> https://onlyoffice.<DOMAIN>.<TPDOMAIN>

• Create the users and share the Public folder with them.


#### AdGuard Home:

• Login on web UI with: 

> Username: admin

> Password: Global.

• On General Settings enable AdGuard browsing security service.

• Set DNS Blocklists and Custom filtering rules on the web UI.

• Rewrite DNS to your domain and wildcard, pointing to your server private ip.

• Set DNS on router and devices to the ip of the server.


#### FAil2Ban:

• The status can be checked with these commands:

	sudo fail2ban-client status sshd

	sudo fail2ban-client status dropbear

	sudo fail2ban-client set <sshd or dropbear> unbanip <ip>


#### Transmission:

• Login on web UI with: 

> Username: root

> Password: Global.

• Change the path to /mnt/Cloud/Public/Downloads.


#### Arrs:

• Login on Arrs to change users and passwords.

• Add the Transmission to download client (without category).

• Add indexers, apps and FlareSolver on Prowlarr.

• Create language profile on bazar, after add providers to turn on Sonarr and Bazarr.


#### Jellyfin and Kavita:

• To force first login on jellyfin use this link "https://jellyfin.<DOMAIN>/web/index.html#/wizardstart".html.

• Create Users and Libraries.

• Do the the first login on kavita and crate Users and Libraries.


#### Immich:

• On Immich Change user and password

• Create Users and Libraries.


### Devices Configuration:


#### On Windows:

• Export SSH Key and VPN Key with Dietpi-Dashboard or Samba.

• Download wireguard on your device and use the private key to do the connection.

• Enable VPN permissions on device.

• Test if ipv6 and ipv4 is ok.

• Create a private key on PuTTYgen (.ppk extension), after delete the Keys from docs.

• Save Private Keys (Secret Folder).

• On putty create a session with the private key.


#### On Android:

• Download wireguard on your device and use the QR code to do the connection.

	pivpn -qr /mnt/Cloud/Public/Keys_VPN/<DEVICE>

• Enable VPN permissions on device.

• Test if ipv6 and ipv4 is ok.

• Export SSH Key with Dietpi-Dashboard or Samba.

• Download Termux and do this commands to add SSH Keys:

	pkg install openssh -y

	eval $(ssh-agent -s)

	cd .ssh

	nano <SERVER>(<USER>) (Put the private key here.)

	ssh-add ~/.ssh/<SERVER>(<USER>)

	nano config

		Host <SERVER>_<USER>
			HostName <DOMAIN><TPDOMAIN>
			USER <USER>
			IdentityFile ~/.ssh/<SERVER>(<USER>)

• To login use this command:

	ssh <SERVER>_<USER>
