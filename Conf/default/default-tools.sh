#Install postgresql.
apt-get install postgresql -y
#Create user and database.
sudo -i -u postgres psql -c "CREATE USER onlyoffice WITH PASSWORD '$(echo "$2")';"
sudo -i -u postgres psql -c 'CREATE DATABASE onlyoffice WITH OWNER onlyoffice;'
#Install rabbitmq-server.
apt-get install rabbitmq-server -y
#Change port to 8090
echo onlyoffice-documentserver onlyoffice/ds-port select 8090 | sudo debconf-set-selections
#Go to Data.
cd /mnt/Cloud/Data
#Add GPG key.
mkdir -p -m 700 ~/.gnupg
curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --import
chmod 644 /tmp/onlyoffice.gpg
chown root:root /tmp/onlyoffice.gpg
mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg
#Add ONLYOFFICE Docs repository.
echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main" | sudo tee /etc/apt/sources.list.d/onlyoffice.list
#Update
apt-get update -y
#Install ttf-mscorefonts-installer.
apt-get install ttf-mscorefonts-installer -y
#Install Onlyoffice.
apt-get install onlyoffice-documentserver -y
#Change /etc/nginx/nginx.conf with "variables_hash_max_size 2048;".
sed '$ d' /etc/nginx/nginx.conf > nginx.conf
echo -e '\n        variables_hash_max_size 2048;\n}' >> nginx.conf
mv nginx.conf /etc/nginx

#Install Samba Client and Nextcloud.
/boot/dietpi/dietpi-software install 1 114

#Change Nextcloud configs.
sudo apt-get install php-bcmath php-gmp php-imagick libmagickcore-6.q16-6-extra -y
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set maintenance_window_start --type=integer --value=1
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set opcache.interned_strings_buffer --type=integer --value=9
sudo -u www-data php8.2 /var/www/nextcloud/occ maintenance:repair --include-expensive
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set default_phone_region --value="BR"
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set datadirectory --value="/mnt/Cloud/Data/nextcloud_data"
sudo mv /mnt/dietpi_userdata/nextcloud_data /mnt/Cloud/Data
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set maintenance_window_start --type=integer --value=0
#Remove default files.
cd /etc/nginx/sites-dietpi
rm -rf dietpi-dav_redirect.conf dietpi-nextcloud.conf

#Go to Immich Docker directory.
cd /mnt/Cloud/Data/Docker/immich-app
#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS_Exential/Conf/Docker/Immich/docker-compose.yml .
#Change Data Base password.
echo -e "UPLOAD_LOCATION=/mnt/Cloud/Data/Docker/immich-app/immich-files\nDB_DATA_LOCATION=/mnt/Cloud/Data/Docker/immich-app/postgres\nIMMICH_VERSION=release\nDB_USERNAME=postgres\nDB_DATABASE_NAME=immich\nDB_PASSWORD=$1" >> .env
#Add user folders to immich.
cd /mnt/Cloud/Data/Docker/immich-app
echo -e "      - /mnt/Cloud/$6/Midias/Midias-Anuais:/mnt/Cloud/$6/Midias/Midias-Anuais" >> docker-compose.yml
#Run Immich on Docker.
docker compose up -d

#Go to Vscodium Docker directory.
cd /mnt/Cloud/Data/Docker/vscodium
#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS_Exential/Conf/Docker/Vscodium/docker-compose.yml .
#Run Vscodium on Docker.
docker compose up -d

#Go to Gimp Docker directory.
cd /mnt/Cloud/Data/Docker/gimp
#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS_Exential/Conf/Docker/Gimp/docker-compose.yml .
#Run Gimp on Docker.
docker compose up -d

#Go to Stirling Docker directory.
cd /mnt/Cloud/Data/Docker/stirling
#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS_Exential/Conf/Docker/Stirling/docker-compose.yml .
#Run Stirling on Docker.
docker compose up -d
echo -e 'cd /mnt/Cloud/Data/Docker/stirling\nsudo docker compose up -d' >> /mnt/Cloud/Data/Commands/reboot.sh

#Go to Passbolt Docker directory.
cd /mnt/Cloud/Data/Docker/passbolt
#Create and Import default file.
echo -e 'services:\n  db:\n    image: mariadb:10.11\n    restart: unless-stopped\n    environment:\n      MYSQL_RANDOM_ROOT_PASSWORD: "true"\n      MYSQL_DATABASE: "passbolt"\n      MYSQL_USER: "passbolt"\n      MYSQL_PASSWORD: "'"$(echo "$3")"'"\n    volumes:\n      - database_volume:/var/lib/mysql\n' >> docker-compose-ce.yaml
echo -e '  passbolt:\n    image: passbolt/passbolt:latest-ce\n    restart: unless-stopped\n    depends_on:\n      - db\n    environment:\n      APP_FULL_BASE_URL: https://passbolt.'"$4$5"'\n      DATASOURCES_DEFAULT_HOST: "db"\n      DATASOURCES_DEFAULT_USERNAME: "passbolt"\n      DATASOURCES_DEFAULT_PASSWORD: "'"$(echo "$3")"'"\n      DATASOURCES_DEFAULT_DATABASE: "passbolt"\n      PASSBOLT_SECURITY_SMTP_SETTINGS_ENDPOINTS_DISABLED: "false"' >> docker-compose-ce.yaml
echo -e '    volumes:\n      - gpg_volume:/etc/passbolt/gpg\n      - jwt_volume:/etc/passbolt/jwt\n    command:\n      [\n        "/usr/bin/wait-for.sh",\n        "-t",\n        "0",\n        "db:3306",\n        "--",\n        "/docker-entrypoint.sh",\n      ]\n    ports:\n      - 8050:80\n\nvolumes:\n  database_volume:\n  gpg_volume:\n  jwt_volume:' >> docker-compose-ce.yaml
curl -LO https://github.com/passbolt/passbolt_docker/releases/latest/download/docker-compose-ce-SHA512SUM.txt
#Run Passbolt on Docker.
docker compose -f docker-compose-ce.yaml up -d

#Passbolt security configs.
chmod 770 /mnt/dietpi_userdata/docker-data/volumes/passbolt_jwt_volume/_data
cd /mnt/Cloud/Data/Docker/passbolt
docker compose -f docker-compose-ce.yaml exec -ti passbolt su -s /bin/bash -c "source /etc/environment && /usr/share/php/passbolt/bin/cake passbolt create_jwt_keys" www-data
chown -R root:www-data /mnt/dietpi_userdata/docker-data/volumes/passbolt_jwt_volume/_data
chmod 750 /mnt/dietpi_userdata/docker-data/volumes/passbolt_jwt_volume/_data
chmod 640 /mnt/dietpi_userdata/docker-data/volumes/passbolt_jwt_volume/_data/jwt.pem
chmod 640 /mnt/dietpi_userdata/docker-data/volumes/passbolt_jwt_volume/_data/jwt.key

#Passbolt Healthcheck
sudo docker compose -f docker-compose-ce.yaml exec -ti passbolt su -s /bin/bash -c "source /etc/environment && /usr/share/php/passbolt/bin/cake passbolt healthcheck --jwt" www-data

#Go to Esphome Docker directory.
cd /mnt/Cloud/Data/Docker/esphome
#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS_Exential/Conf/Docker/Esphome/docker-compose.yml .
echo -e '      - PASSWORD='"$(echo "$8")"'' >> docker-compose.yml
#Run Esphome on Docker.
docker compose up -d
