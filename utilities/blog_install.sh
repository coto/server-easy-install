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
v_wpmu="2.9.2"
v_bp="1.2.3"

yum install -y unzip
#http://www.todowp.org/download/21/
rm -rf aqua
svn co http://svn.protoboard.cl/aqua/trunk aqua
cd aqua

####################################################################
# Get WordPress by version setted
####################################################################
svn export http://svn.automattic.com/wordpress/tags/$v_wpmu/ ./ --force
svn status | grep "^\?" | awk '{print $2}' | xargs svn add
svn ci -m "WPMU $v_wpmu"

####################################################################
# Get WordPress MU by version setted (Deprecated)
####################################################################
# svn export http://svn.automattic.com/wordpress-mu/tags/$v_wpmu/ ./ --force
# svn status | grep "^\?" | awk '{print $2}' | xargs svn add
# svn ci -m "WPMU $v_wpmu"

####################################################################
# Get BuddyPress by version setted
####################################################################
svn export http://svn.buddypress.org/tags/$v_bp/ ./wp-content/plugins/buddypress
svn status | grep "^\?" | awk '{print $2}' | xargs svn add
svn ci -m "BP $v_bp"

####################################################################
# WPMU es_ES
####################################################################
# wget http://www.buddypress-es.com/downloads/lockdown/wordpress292Premium.zip
# mkdir -p ./wp-content/languages/
# unzip wordpress292Premium.zip -d ./wp-content/languages/
# rm -f wordpress292Premium.zip
# svn status | grep "^\?" | awk '{print $2}' | xargs svn add
# svn ci -m "WPMU $v_wpmu - es_ES"

####################################################################
# BP es_ES
####################################################################
wget http://www.buddypress-es.com/downloads/lockdown/buddypress-es_ES-$v_bp.zip
unzip buddypress-es_ES-$v_bp.zip -d ./wp-content/plugins/buddypress/bp-languages/
rm -f buddypress-es_ES-$v_bp.zip
svn status | grep "^\?" | awk '{print $2}' | xargs svn add
svn ci -m "BP $v_bp - es_ES"

####################################################################
# Publish on Site
####################################################################
svn export http://svn.protoboard.cl/aqua/trunk /var/www/html/aqua.protoboard/ --force
chown -R apache:apache /var/www/trac/ /var/www/svn/ /var/www/html/
chmod 777 /var/www/html/aqua.protoboard/wp-content/

cd ../
rm -rf aqua/

echo -e "
	define('WP_MEMORY_LIMIT', '96M');
	define('BP_ENABLE_USERNAME_COMPATIBILITY_MODE', 'true' );
" >> /var/www/html/aqua.protoboard/wp-config-sample.php


