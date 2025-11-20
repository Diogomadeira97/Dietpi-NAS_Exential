#! /bin/bash

echo -e "server{\n	listen 80;\n	listen [::]:80;\n	server_name $3.$1$2;\n	return 301 https://\$host\$request_uri;	\n}\n\nserver{\n	listen 443 ssl;\n	listen [::]:443 ssl;\n	http2 on;\n	server_name $3.$1$2;\n	ssl_certificate /etc/letsencrypt/live/$1$2/fullchain.pem;\n	ssl_certificate_key /etc/letsencrypt/live/$1$2/privkey.pem;\n	set \$url $5:$4;\n\n" >> /etc/nginx/sites-available/$3
echo -e "	location / {\n		proxy_pass http://\$url;\n		proxy_set_header Host \$host;\n		proxy_set_header X-Real-IP \$remote_addr;\n		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n		proxy_set_header X-Forwarded-Proto \$scheme;\n		proxy_set_header X-Forwarded-Protocol \$scheme;\n		proxy_set_header X-Forwarded-Host \$http_host;\n		proxy_buffering off;\n	}\n\n" >> /etc/nginx/sites-available/$3
echo -e "	location /socket {\n		proxy_pass http://\$url;\n		proxy_http_version 1.1;\n		proxy_set_header Upgrade \$http_upgrade;\n		proxy_set_header Connection "upgrade";\n		proxy_set_header Host \$host;\n		proxy_set_header X-Real-IP \$remote_addr;\n		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n		proxy_set_header X-Forwarded-Proto \$scheme;\n		proxy_set_header X-Forwarded-Protocol \$scheme;\n		proxy_set_header X-Forwarded-Host \$http_host;\n	}\n}" >> /etc/nginx/sites-available/$3

sudo chown root:root /etc/nginx/sites-available/$3
sudo chmod 544 /etc/nginx/sites-available/$3

cd /etc/nginx/sites-enabled

sudo ln -s /etc/nginx/sites-available/$3 .

echo -e "sudo iptables -A INPUT -p tcp ! -s $5 --dport $4 -j DROP" >> /mnt/Cloud/Data/Commands/iptables_custom.sh

sudo nginx -s reload
