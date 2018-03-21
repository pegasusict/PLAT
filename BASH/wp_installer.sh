#!/bin/bash
###############################################################################
# Pegasus' Linux Administration Tools                     WP installer script #
# (C)2017-2018 Mattijs Snepvangers                      pegasus.ict@gmail.com #
# License: GPL v3                          Please keep my name in the credits #
###############################################################################
START_TIME=$(date +"%Y-%m-%d_%H.%M.%S.%3N")
echo "$START_TIME ## Starting PostInstall Process #######################"
################### PROGRAM INFO ##############################################
PROGRAM_SUITE="Pegasus' Linux Administration Tools"
SCRIPT_TITLE="WordPress site installer"
MAINTAINER="Mattijs Snepvangers"
MAINTAINER_EMAIL="pegasus.ict@gmail.com"
VERSION_MAJOR=0
VERSION_MINOR=0
VERSION_PATCH=0
VERSION_STATE="ALPHA"
VERSION_BUILD=201803021
###############################################################################
PROGRAM="$PROGRAM_SUITE - $SCRIPT"
SHORT_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$VERSION_STATE"
VERSION="Ver$SHORT_VERSION build $VERSION_BUILD"
###############################################################################
# Making sure this script is run by bash to prevent mishaps
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then bash "$0" "$@" ; exit "$?" ; fi
# Make sure only root can run this script
if [[ $EUID -ne 0  ]]; then echo "This script must be run as root" ; exit 1 ; fi
# set default values
CURR_YEAR=$(date +"%Y")			;		TODAY=$(date +"%d-%m-%Y")	;	VERBOSITY=2
LOGDIR="/var/log/plat"			;		SCRIPT_DIR="/etc/plat"
LOGFILE="$LOGDIR/WPinstall_$START_TIME.log"
#MAIL_SCRIPT="$SCRIPT_DIR/mail.sh"	;	MAIL_SCRIPT_TITLE="Email Script"
#ASK_FOR_EMAIL_STUFF=true
#EMAIL_SENDER=false;	EMAIL_RECIPIENT=false;	EMAIL_PASSWORD=false
#COMPUTER_NAME=$(uname -n)
WP_DOMAIN="wordpress.peteris.rocks"
WP_ADMIN_USERNAME="admin"
WP_ADMIN_PASSWORD="admin"
WP_ADMIN_EMAIL="no@spam.org"
WP_DB_NAME="wordpress"
WP_DB_USERNAME="wordpress"
WP_DB_PASSWORD="wordpress"
WP_PATH="/var/www/wordpress"
MYSQL_ROOT_PASSWORD="root"
###################### defining functions #####################################
download() { wget -q -a "$LOGFILE" -nv $1; }
gen_rnd_pw(){
	apt install pwgen
	WP_DB_PASSWORD="$(pwgen -1 -s 64)"
	MYSQL_ROOT_PASSWORD="$(pwgen -1 -s 64)"
}
install_wp(){
	mkdir -p $WP_PATH/public $WP_PATH/logs
	rm -rf $WP_PATH/public/ # !!!
	mkdir -p $WP_PATH/public/
	chown -R $USER $WP_PATH/public/
	cd $WP_PATH/public/

	download "https://wordpress.org/latest.tar.gz"
	tar xf latest.tar.gz --strip-components=1
	rm latest.tar.gz

	mv wp-config-sample.php wp-config.php
	sed -i s/database_name_here/$WP_DB_NAME/ wp-config.php
	sed -i s/username_here/$WP_DB_USERNAME/ wp-config.php
	sed -i s/password_here/$WP_DB_PASSWORD/ wp-config.php
	echo "define('FS_METHOD', 'direct');" >> wp-config.php

	chown -R www-data:www-data $WP_PATH/public/

	curl "http://$WP_DOMAIN/wp-admin/install.php?step=2" \
	  --data-urlencode "weblog_title=$WP_DOMAIN"\
	  --data-urlencode "user_name=$WP_ADMIN_USERNAME" \
	  --data-urlencode "admin_email=$WP_ADMIN_EMAIL" \
	  --data-urlencode "admin_password=$WP_ADMIN_PASSWORD" \
	  --data-urlencode "admin_password2=$WP_ADMIN_PASSWORD" \
	  --data-urlencode "pw_weak=1"
}
create_DB(){
	mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE USER '$WP_DB_USERNAME'@'localhost' IDENTIFIED BY '$WP_DB_PASSWORD';
CREATE DATABASE $WP_DB_NAME;
GRANT ALL ON $WP_DB_NAME.* TO '$WP_DB_USERNAME'@'localhost';
EOF
}
install_ssl_certs(){
sudo apt install -y letsencrypt

sudo mkdir -p $WP_PATH
sudo letsencrypt certonly -n --agree-tos --webroot -w $WP_PATH -d $WP_DOMAIN -d www.$WP_DOMAIN -m $WP_ADMIN_EMAIL
sudo openssl dhparam -out /etc/letsencrypt/live/$WP_DOMAIN/dhparam.pem 2048
### periodically renew certs
sudo tee /etc/cron.daily/letsencrypt <<EOF
letsencrypt renew --agree-tos && systemctl restart apache
EOF
chmod +x /etc/cron.daily/letsencrypt
}
update_server_config(){ ###TODO### nginx config, change to apache config
	tee /etc/nginx/sites-available/$WP_DOMAIN <<EOF
server {
  listen 80;
  server_name $WP_DOMAIN www.$WP_DOMAIN;
  return 301 https://\$server_name\$request_uri;
}

server {
  listen 443 ssl http2;
  server_name $WP_DOMAIN www.$WP_DOMAIN;

  root $WP_PATH/public;
  index index.php;

  access_log $WP_PATH/logs/access.log;
  error_log $WP_PATH/logs/error.log;

  ssl_certificate           /etc/letsencrypt/live/$WP_DOMAIN/fullchain.pem;
  ssl_certificate_key       /etc/letsencrypt/live/$WP_DOMAIN/privkey.pem;
  ssl_trusted_certificate   /etc/letsencrypt/live/$WP_DOMAIN/chain.pem;
  ssl_dhparam               /etc/letsencrypt/live/$WP_DOMAIN/dhparam.pem;

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
  ssl_prefer_server_ciphers on;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;
  ssl_stapling on;
  ssl_stapling_verify on;
  resolver 8.8.4.4 8.8.8.8 valid=300s;
  resolver_timeout 10s;

  add_header Strict-Transport-Security max-age=15552000;

  location / {
    try_files \$uri \$uri/ /index.php?\$args;
  }

  location ~ \.php\$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php7.0-fpm.sock;
  }
}
EOF
	systemctl restart nginx
}
secure_wp(){
	echo "add_filter( 'allow_dev_auto_core_updates', '__return_false' );" >> wp-config.php
	echo "add_filter( 'allow_minor_auto_core_updates', '__return_true' );" >> wp-config.php
	echo "add_filter( 'allow_major_auto_core_updates', '__return_true' );" >> wp-config.php
	echo "add_filter( 'auto_update_plugin', '__return_true' );" >> wp-config.php
	echo "add_filter( 'auto_update_theme', '__return_true' );" >> wp-config.php
	echo "define('DISALLOW_FILE_EDIT', true);" >> wp-config.php
	sed -i "s/define('AUTH_KEY',\s*'put your unique phrase here');/define('AUTH_KEY', '`pwgen -1 -s 64`');/" wp-config.php
	sed -i "s/define('SECURE_AUTH_KEY',\s*'put your unique phrase here');/define('SECURE_AUTH_KEY', '`pwgen -1 -s 64`');/" wp-config.php
	sed -i "s/define('LOGGED_IN_KEY',\s*'put your unique phrase here');/define('LOGGED_IN_KEY', '`pwgen -1 -s 64`');/" wp-config.php
	sed -i "s/define('NONCE_KEY',\s*'put your unique phrase here');/define('NONCE_KEY', '`pwgen -1 -s 64`');/" wp-config.php
	sed -i "s/define('AUTH_SALT',\s*'put your unique phrase here');/define('AUTH_SALT', '`pwgen -1 -s 64`');/" wp-config.php
	sed -i "s/define('SECURE_AUTH_SALT',\s*'put your unique phrase here');/define('SECURE_AUTH_SALT', '`pwgen -1 -s 64`');/" wp-config.php
	sed -i "s/define('LOGGED_IN_SALT',\s*'put your unique phrase here');/define('LOGGED_IN_SALT', '`pwgen -1 -s 64`');/" wp-config.php
	sed -i "s/define('NONCE_SALT',\s*'put your unique phrase here');/define('NONCE_SALT', '`pwgen -1 -s 64`');/" wp-config.php
	mv $WP_PATH/public/wp-config.php $WP_PATH/wp-config.php
	chown -R root:root $WP_PATH
	chown -R $USER $WP_PATH/public/
	chown -R www-data:www-data $WP_PATH/public/wp-content/
	rm $WP_PATH/public/readme*
}
###############################################################################
if [ GEN_RAND_PW == true ] ; then gen_rnd_pw ; fi
create_DB
update_server_config
install_ssl_certs
install_wp
secure_wp

echo <<EOT
install plugins:
>    Wordfense Security
>    WP Security Audit Log
>    Security Ninja
EOT

###TODO### Improvements to be made:
#
#    Redirect www to non-www
#    Use wp-cli instead of curl
#    Install some plugins
#    Automatic updates
#    Mail server
#    Automatic backups
#    Ansible script
#    Optional slack monitoring
#    Rotate apache logs
