#!/bin/bash
# Simple LadyClaire SSH Panel installer for OCS Panel-installed vps server
# 
# SSH panel by Dreyannz
# Script by Bonveio

##Config##

# Your Hostname (must be pointed with CloudFlare for extra security)
myHostname='trial.xbalanced-vpn.tech'

# Your Website Name
mySiteName='xBalanced'

##########

if [[ $EUID -ne 0 ]]; then
 echo -e "[\e[1;31mError\e[0m] This script must be run as root, exiting..."
 exit 1
fi

if [[ ! -e /home/panel/html ]]; then
 echo -e "[\e[1;31mError\e[0m] This script must be used together with Bon-chan's OCS Panel installer, exiting..."
 exit 1
fi

if [[ -e /etc/nginx/conf.d/bonveio-panel.conf ]]; then
 nginxC="/etc/nginx/conf.d/$mySiteName-panel.conf"
 else
 nginxC="/etc/nginx/conf.d/bonveio-panel.conf"
fi

cat <<'EOFn' > "$nginxC"
server {
 listen 80;
 server_name bDOMAIN;
 access_log /var/log/nginx/sshpanel-access.log;
 error_log /var/log/nginx/sshpanel-error.log error;
 root bDIR;
 
 location / {
  index index.html index.htm index.php;
  try_files $uri $uri/ /index.php?$args;
  }
  
 location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9005;
  fastcgi_index index.php;
  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  }
}
EOFn

sed -i "s|bDOMAIN|$myHostname|g" "$nginxC"
sed -i "s|bDIR|/home/panel/$mySiteName|g" "$nginxC"

mkdir -p "/home/panel/$mySiteName"
cd "/home/panel/$mySiteName"
chown -R www-data:www-data "/home/panel/$mySiteName"
chmod -R g+rw "/home/panel/$mySiteName"

wget -qO index.php 'https://raw.githubusercontent.com/Dreyannz/VPS_Site/master/Version%203.0/index.php'

cat <<'EOF' > server.php
<?php
 $site_name = "xBalanced";
 $site_description = "Premium VPN Accounts, Fast and Reliable Servers";
 $site_template = "lumen";
 $daily_limit_user = "50";
 
 //Array: "Server_name or Server country","ip address of server","server_owner","account expiry days"
 $server_lists_array=array(
  1=>array(1=>"Singapore 1","128.199.100.20","xBalanced","5"),
  2=>array(1=>"Singapore 2","128.199.100.30","xBalanced","5"),
  3=>array(1=>"Singapore 3","128.199.100.40","xBalanced","5"),
); 

/* Service Variables */
// SSH Ports
$port_ssh= '22, 225';
// Dropbear Ports
$port_dropbear= '550, 555';
// Stunnel Ports
$port_ssl= '443, 444';
// Proxy Ports
$port_squid= '8000, 8080';
// OpenVPN Config download
$ovpn_client= ''.$hosts.'/SunConfig.ovpn';

?>
EOF

systemctl restart php5.6-fpm.service
systemctl restart nginx.service

echo -e " Success Adding SSH Panel on your server"
echo -e " You may visit your SSH Panel at http://$myHostname"
echo -e ""
exit 1