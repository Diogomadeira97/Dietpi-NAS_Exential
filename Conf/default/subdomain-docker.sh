#! /bin/bash

echo -e "server{\n	listen 80;\n	listen [::]:80;\n	server_name $3.$1$2;\n	return 301 https://\$host\$request_uri;	\n}\n\nserver{\n	listen 443 ssl http2;\n	listen [::]:443 ssl http2;\n	server_name $3.$1$2;\n	ssl_certificate /etc/letsencrypt/live/$1$2/fullchain.pem;\n	ssl_certificate_key /etc/letsencrypt/live/$1$2/privkey.pem;\n	set \$url $5:$4;\n\n" >> /etc/nginx/sites-available/$3
echo -e "	location / {\n		proxy_pass http://\$url;\n		proxy_http_version 1.1;\n		proxy_set_header Upgrade \$http_upgrade;\n		proxy_set_header Connection 'upgrade';\n		proxy_set_header Host \$host;\n		proxy_cache_bypass \$http_upgrade;\n	}\n\n	location /.well-known/acme-challenge/ {\n		allow all;\n	}\n}" >> /etc/nginx/sites-available/$3

sudo chown root:root /etc/nginx/sites-available/$3
sudo chmod 544 /etc/nginx/sites-available/$3

cd /etc/nginx/sites-enabled

sudo ln -s /etc/nginx/sites-available/$3 .

echo -e "sudo iptables -A INPUT -p tcp ! -s $5 --dport $4 -j DROP" >> /mnt/Cloud/Data/Commands/iptables_custom.sh

sudo nginx -s reload