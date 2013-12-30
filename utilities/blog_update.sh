#!/bin/sh
####################################################################
# Update Any Blog Project from a Head revision of SVN
# Author: Coto Augosto C.
# URL: http://beecoss.com
# Created: Mar 22, 2010 04:44:42
####################################################################

host=$1
project=$2

if [ "$host" = "" ]; then
	echo -e "Beecoss for example:"
	read host
fi

if [ "$project" = "" ]; then
	echo -e "Project Name:"
	read project
fi

####################################################################
# Export Site from SVN Head & Personal Design from SVN Head
####################################################################
sudo svn export http://svn.$host.cl/$project/trunk/ /var/www/html/$project/ --force
sudo svn export http://svn.$host.cl/$project/trunk/personal_design /var/www/html/$project/ --force

####################################################################
# Protection
####################################################################
echo "Setting Permissions"
sudo chown apache:apache -R /var/www/html/$project/
sudo chmod 755 -R /var/www/html/$project/

sudo chmod 640 /var/www/html/$project/.htaccess
sudo chmod 640 /var/www/html/$project/wp-settings.php
sudo chmod 640 /var/www/html/$project/wp-config.php
if [ -f /var/www/html/$project/wpmu-settings.php ]; then
	sudo chmod 640 /var/www/html/$project/wpmu-settings.php
fi
if [ -f /var/www/html/$project/wp-content/wp-cache-config.php ]; then
	sudo chmod 640 /var/www/html/$project/wp-content/wp-cache-config.php
fi
