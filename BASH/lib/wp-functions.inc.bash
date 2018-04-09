#!/bin/bash
###############################################################################
# Pegasus' Linux Administration Tools                    WP Functions Library #
# (C)2017-2018 Mattijs Snepvangers                      pegasus.ict@gmail.com #
# License: GPL v3                          Please keep my name in the credits #
###############################################################################

#######################################################
# PROGRAM_SUITE="Pegasus' Linux Administration Tools" #
# SCRIPT_TITLE="WordPress Functions Library"          #
# MAINTAINER="Mattijs Snepvangers"                    #
# MAINTAINER_EMAIL="pegasus.ict@gmail.com"            #
# VERSION_MAJOR=0                                     #
# VERSION_MINOR=0                                     #
# VERSION_PATCH=12                                    #
# VERSION_STATE="ALPHA"                               #
# VERSION_BUILD=201803029                             #
#######################################################

## WordPress ##################################################################
# mod: WordPress
# txt: This module holds functions specifically aimed at installing WordPress


install_wp() { ###TODO###    Use wp-cli instead of curl
	# fun: install_wp
	# txt: Installs WordPress according to preferences given in
	#      the ini file and/or command line arguments
	# use: install_wp
	# api: WordPress
	chown -R $WP_USER "$WP_PUBLIC"
	cd "$WP_PUBLIC"
	download "https://wordpress.org/latest.tar.gz"
	tar xf latest.tar.gz --strip-components=1
	rm latest.tar.gz
	mv wp-config-sample.php $WP_CFG
	sed -i s/database_name_here/$WP_DB_NAME/ "$WP_CFG"
	sed -i s/username_here/$WP_DB_USERNAME/ "$WP_CFG"
	sed -i s/password_here/$WP_DB_PASSWORD/ "$WP_CFG"
	echo "define('FS_METHOD', 'direct');" >> "$WP_CFG"
	chown -R www-data:www-data "$WP_PUBLIC"
	wp-cli_install
	wp core download --path=$WP_PATH --locale=$WP_LOCALE --version=latest --force | info_line
	wp core install

	###TODO###    Use wp-cli instead of curl
	curl "http://$WP_DOMAIN/wp-admin/install.php?step=2" \
		--data-urlencode "weblog_title=$WP_DOMAIN"\
		--data-urlencode "user_name=$WP_ADMIN_USERNAME" \
		--data-urlencode "admin_email=$WP_ADMIN_EMAIL" \
		--data-urlencode "admin_password=$WP_ADMIN_PASSWORD" \
		--data-urlencode "admin_password2=$WP_ADMIN_PASSWORD" \
		--data-urlencode "pw_weak=1"
}
secure_wp() {
	echo "add_filter( 'allow_dev_auto_core_updates', '__return_false' );" >> "$WP_CFG"
	echo "add_filter( 'allow_minor_auto_core_updates', '__return_true' );" >> "$WP_CFG"
	echo "add_filter( 'allow_major_auto_core_updates', '__return_true' );" >> "$WP_CFG"
	echo "add_filter( 'auto_update_plugin', '__return_true' );" >> "$WP_CFG"
	echo "add_filter( 'auto_update_theme', '__return_true' );" >> "$WP_CFG"
	echo "define('DISALLOW_FILE_EDIT', true);" >> "$WP_CFG"
	sed -i "s/define('AUTH_KEY',\s*'put your unique phrase here');/define('AUTH_KEY', '$(gen_rnd_pw)');/" "$WP_CFG"
	sed -i "s/define('SECURE_AUTH_KEY',\s*'put your unique phrase here');/define('SECURE_AUTH_KEY', '$(gen_rnd_pw)');/" "$WP_CFG"
	sed -i "s/define('LOGGED_IN_KEY',\s*'put your unique phrase here');/define('LOGGED_IN_KEY', '$(gen_rnd_pw)');/" "$WP_CFG"
	sed -i "s/define('NONCE_KEY',\s*'put your unique phrase here');/define('NONCE_KEY', '$(gen_rnd_pw)');/" "$WP_CFG"
	sed -i "s/define('AUTH_SALT',\s*'put your unique phrase here');/define('AUTH_SALT', '$(gen_rnd_pw)');/" "$WP_CFG"
	sed -i "s/define('SECURE_AUTH_SALT',\s*'put your unique phrase here');/define('SECURE_AUTH_SALT', '$(gen_rnd_pw)');/" "$WP_CFG"
	sed -i "s/define('LOGGED_IN_SALT',\s*'put your unique phrase here');/define('LOGGED_IN_SALT', '$(gen_rnd_pw)');/" "$WP_CFG"
	sed -i "s/define('NONCE_SALT',\s*'put your unique phrase here');/define('NONCE_SALT', '$(gen_rnd_pw)');/" "$WP_CFG"
	mv $WP_PATH/public/"$WP_CFG" $WP_PATH/"$WP_CFG"
	chown -R root:root $WP_PATH
	chown -R $WP_USER $WP_PATH/public/
	chown -R www-data:www-data $WP_PATH/public/wp-content/
	rm $WP_PATH/public/readme*
}
install_wp_cli() {
	# fun: install_wp_cli
	# txt: Installs WordPress Command Line Interface API
	# use: install_wp_cli
	# api: WordPress
	download "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
}
update_wp_cli() {
	# fun: update_wp_cli
	# txt: Updates WordPress Command Line Interface API
	# use: update_wp_cli
	# api: WordPress
	wp cli update | verb_line
}
wp_plugin_install() {
	# fun: wp_plugin_install <plugin>
	# txt: Installs & activates a WordPress plugin
	#      <plugin|zip|url>
    One or more plugins to install. Accepts a plugin slug, the path to a local zip file, or a URL to a remote zip file.
	# use: wp_plugin_install <plugin|zip|url>
    One or more plugins to install. Accepts a plugin slug, the path to a local zip file, or a URL to a remote zip file.
[--version=<version>]
    If set, get that particular version from wordpress.org, instead of the stable version.
[--force]
    If set, the command will overwrite any installed version of the plugin, without prompting for confirmation.
[--activate]
    If set, the plugin will be activated immediately after install.
[--activate-network]
    If set, the plugin will be network activated immediately after install 
	# api: WordPress
	local _PLUGIN="$1"
	wp plugin install $_PLUGIN --activate | verb_line
}

### WordPress - DB #############################################################
setup_DB() {
	# fun: setup_DB
	# txt: Creates a Database and a Database user/pass,
	#      Grants given user all right on given Database
	# use: setup_DB
	# api: WordPress
	mysql -u root -p$DB_ROOT_PASSWORD <<-EOT
	CREATE USER '$DB_USERNAME'@'localhost' WITH mysql_native_password AS '$DB_PASSWORD';
	GRANT USAGE ON *.* TO 'DB_USERNAME'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
	CREATE DATABASE IF NOT EXISTS `$DB_NAME`;
	GRANT ALL ON $DB_NAME.* TO '$DB_USERNAME'@'localhost';
	GRANT ALL PRIVILEGES ON `$DB_NAME\_%`.* TO 'DB_USER_NAME'@'localhost';
	EOT
}

### WordPress - webserver ######################################################
update_server_config() { ###TODO### nginx config, change to apache config
	<plugin>
	tee /etc/nginx/sites-available/$WP_DOMAIN <<-EOT
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
EOT
	systemctl restart nginx
}
install_ssl_certs() { ## generates certificates and adds a daily cronjob to update them
	letsencrypt certonly -n --agree-tos --webroot -w $WP_PATH -d $WP_DOMAIN -d www.$WP_DOMAIN -m $WP_ADMIN_EMAIL
	openssl dhparam -out /etc/letsencrypt/live/$WP_DOMAIN/dhparam.pem 2048
	### periodically renew certs
	local $_TARGET="/etc/cron.daily/letsencrypt"
	local $_LINE=<<-EOT
	letsencrypt renew --agree-tos && systemctl restart apache
	EOT
	create_file "$_TARGET"
	add_line_to_file "$_LINE" "$_TARGET"
	chmod +x "$_TARGET"
}

### MISCELLANIOUS ##############################################################
gen_rnd_pw() { ### generates random password
	echo "$(pwgen -1 -s 64)"
}
