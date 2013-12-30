#!/bin/bash
####################################################################
# Installation of WordPress and BuddyPress
# Author: Coto Augosto C.
# URL: http://beecoss.com
# Created: Mar 22, 2010 04:44:42
####################################################################


####################################################################
# Set Versions
####################################################################
v_wpmu="3.8"

yum install -y unzip
rm -rf aqua
svn co http://svn.beecoss.com/aqua/trunk aqua
cd aqua

####################################################################
# Get WordPress by version setted
####################################################################
svn export http://svn.automattic.com/wordpress/tags/$v_wpmu/ ./ --force
svn status | grep "^\?" | awk '{print $2}' | xargs svn add
svn ci -m "WPMU $v_wpmu"


####################################################################
# Publish on Site
####################################################################
svn export http://svn.beecoss.com/aqua/trunk /var/www/html/aqua.beecoss/ --force
chown -R apache:apache /var/www/trac/ /var/www/svn/ /var/www/html/
chmod 777 /var/www/html/aqua.beecoss/wp-content/

cd ../
rm -rf aqua/

echo -e "
	define('WP_MEMORY_LIMIT', '96M');
	define('BP_ENABLE_USERNAME_COMPATIBILITY_MODE', 'true' );
" >> /var/www/html/aqua.beecoss/wp-config-sample.php


