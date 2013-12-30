
cronBackup(){
if [ ! `whoami` = "root" ]; then 
	echo -e "$red Error: You must to be ROOT user to run this function $endColor"
	return
fi
sudo mkdir -p $folder_Backup > /dev/null
sudo echo "
#!/bin/sh
####################################################################
# A simple backup script to SVN, TRAC, MYSQL & APACHE FOLDERS
# Author: Coto Augosto C. / Rodrigo Bustos L.
# URL: http://beecoss.com
# Created: Mar 22, 2010 04:44:42
# Version: 3.4
#######################     Instrucctions     ######################
# please be aware that you may need extra space on $folder_Backup
# how to use it:
# copy this script as root to /etc/cron.daily or /etc/cron.weekly as you want
# and set up properly permissions as shown below:
# cp simple-backup.sh /etc/cron.daily
# chmod +x /etc/cron.daily/simple-backup.sh
#
# How to test it:
# bash /etc/cron.daily/simple-backup.sh


####################################################################
# Define Some variables
####################################################################
FOLDER_BACKUP=$folder_Backup
dbuser=$user
dbpass=$passwd
today=\$(date +%Y%m%d-%H%M%S)

mkdir -p \$FOLDER_BACKUP > /dev/null
mkdir -p \$FOLDER_BACKUP/{svn,trac}

####################################################################
# TRAC Dumps
####################################################################
TRACS=\$(ls /var/www/trac/public | awk '{ print \$1}')
for t in \$TRACS
do
	trac-admin /var/www/trac/public/\$t hotcopy \$FOLDER_BACKUP/trac/\$t
done
tar -cvf \$FOLDER_BACKUP/\$today-fol-trac.tar \$FOLDER_BACKUP/trac 2>&1 > /dev/null

####################################################################
# SVN Dumps
####################################################################

SVN=\$(ls /var/www/svn/ | awk '{ print \$1}')
for s in \$SVN
do
	svnadmin dump /var/www/svn/\$s > \$FOLDER_BACKUP/svn/\$s.dump
done
tar -cvf \$FOLDER_BACKUP/\$today-fol-svn.tar \$FOLDER_BACKUP/svn 2>&1 > /dev/null
	
####################################################################
# HTML
####################################################################

tar -cvf \$FOLDER_BACKUP/\$today-fol-html.tar /var/www/html 2>&1 > /dev/null

####################################################################
# MySQL Dumps
####################################################################
DATABASES=\$(mysql -u \$dbuser -p\$dbpass -h localhost  -e 'show databases' | awk '{ print \$1}' | grep -v '^Database' | grep -v '^mysql' | grep -v '^information_schema')
for d in \$DATABASES
do
	mysqldump --opt --user=\$dbuser --password=\$dbpass \$d > \$FOLDER_BACKUP/\$today-db-\$d.sql;
done

####################################################################
# Compress any Dump
####################################################################
# you can use any compressor gzip or bzip2, I suggest to use bzip2 instead gzip especially for text plain files
# mantain this order to free space as soon as possible on the $FOLDER_BACKUP directory
bzip2 -9 \$FOLDER_BACKUP/*.sql 2>&1 > /dev/null
bzip2 -9 \$FOLDER_BACKUP/*.tar 2>&1 > /dev/null

####################################################################
# Remove temps
####################################################################
rm -rf \$FOLDER_BACKUP/{svn,trac}

####################################################################
# Compress Folder Date (Deprecated)
####################################################################
# mkdir -p \$FOLDER_BACKUP/\$today
# mv \$FOLDER_BACKUP/\$today-* /\$FOLDER_BACKUP/\$today/
# tar -cvf \$FOLDER_BACKUP/\$today.tar /\$FOLDER_BACKUP/\$today 2>&1 > /dev/null
" > /etc/cron.daily/simple-backup.sh

	sudo chmod +x /etc/cron.daily/simple-backup.sh
	echo -e "$cyan=============== Cron Backup created successfully ===============$endColor"
}

