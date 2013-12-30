#!/bin/bash
####################################################################
# Restore Backup
# Author: Coto Augosto C.
# URL: http://beecoss.com
# Created: Mar 5, 2010
####################################################################

debug=""
color='\e[1;37;44m'
endColor='\e[0m'
mailAdmin='contact@beecoss.com'

####################################################################
# Get User, password and port
####################################################################

echo -e "$color\n============================ USER / PASS / PORT =============================$endColor"

user=$1
passwd=$2
port=$3

if [ "$user" = "" ]; then
	echo -e "MySQL user:"
	read user
fi

if [ "$passwd" = "" ]; then
	echo -e "MySQL password:"
	read passwd
fi

####################################################################
# TRAC & SVN Config
####################################################################
echo -e "$color\n=============================== TRAC & SVN Config ==================================$endColor"

echo -e "$color How many projects do you want to restore?$endColor"
read nprojects

for i in `seq 1 $nprojects` 
do
	echo -e "$color Project Name $i : $endColor"
	read project_name 

	# Restore Mysql Trac
	mysql -u $user -p$passwd trac_$project_name < *-trac_$project_name.sql
	mysql -u$user -p$passwd -e "GRANT ALL ON trac_$project_name.* TO 'trac'@'localhost' IDENTIFIED BY 'trac';"

	# Restore Folder Trac
	cp -rf trac/$project_name/ /var/www/trac/public/

	# Restore Folder SVN
	cp -rf svn/$project_name/ /var/www/svn/

	# Avoid older configuration path
	sed "/^repository_dir = \/var\/www\/svn\/$project_name.*/ s/^repository_dir = \/var\/www\/svn\/$project_name/repository_dir = \/var\/www\/svn\/$project_name/" /var/www/trac/public/$project_name/conf/trac.ini > tmp
	cat tmp > /var/www/trac/public/$project_name/conf/trac.ini

	echo -e "$color\n#### Folders permission #####$endColor"
	chown -R apache:apache /var/www/trac/ /var/www/svn/ /var/www/html/

	# Upgrade with repository
	trac-admin /var/www/trac/public/$project_name upgrade --no-backup

	# synchronize with repository
	trac-admin /var/www/trac/public/$project_name resync

	# Who is Daddy?
	trac-admin /var/www/trac/public/$project_name permission add $user TRAC_ADMIN
done

sudo /etc/init.d/httpd start 

####################################################################
# Remove Bash History
####################################################################

rm -f tmp
cat /dev/null > ~/.bash_history
history -c
