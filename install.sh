#!/bin/bash
####################################################################
# Fast and Easy Web Server Installation (Optimized for WordPress)
# This script help you to install and configure a Linux server with:
#	- TRAC
#	- SVN
#	- Iptables (More secure)
#	- SSH (Change ports by default and securitize)
#	- Apache, PHP
#	- Django (Web Framework of awesome Python)
#	- MySQL
#	- Mail Server
# Author: Coto Augosto C.
# Help: Rodrigo Bustos L. <rbustosx@gmail.com>
# URL: http://beecoss.com
# Created: Apr 1, 2010 
####################################################################


readonly base_file=`readlink -f "$0"`
readonly base_path=`dirname $base_file`
if [ ! -f $base_path/config ]; then
	echo "Error: You must to create a '$base_path/config' file before, you can create it from '$base_path/config.sample' "
	exit
fi

. "$base_path/config"
. "$base_path/functions/global.sh"
. "$base_path/lib/mailserver.sh"
. "$base_path/lib/cron-backup.sh"
. "$base_path/lib/hook-svn/hooks_svn.sh"
. "$base_path/lib/dns.sh"
. "$base_path/lib/core.sh"

if [[ $DistroBasedOn = "debian" ]]; then
	. "$base_path/functions/debian.sh"
elif [[ $DistroBasedOn = "redhat" ]]; then
	. "$base_path/functions/redhat.sh"
else
	echo "Impossible to run this script in your computer, because it's not a recognizable distribution!!!"
fi

printMenu

