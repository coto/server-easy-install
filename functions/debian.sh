####################################################################
# Vars
####################################################################
echo "debian functions were loaded"
apache_conf='/etc/apache2/apache2.conf'
apache_user='www-data'
ssh_service='/etc/init.d/ssh'
mysql_service='mysql'
apache_service='/etc/init.d/apache2'

userProfile='export PS1="\[\e[0;36m\]\u\[\e[1;33m\]@\H \[\033[0;36m\] \w\[\e[0m\]$ "'
rootProfile='export PS1="\[\e[1;31m\]\u\[\e[1;33m\]@\H \[\033[0;36m\] \w\[\e[0m\]$ "'

####################################################################
# Create USER
####################################################################
createUser(){
	if [ ! `whoami` = "root" ]; then 
		echo -e "$red Error: You must to be ROOT user to run this function $endColor"
		return
	fi
	echo -e "$cyan============================ Creating a user $user... =============================$endColor"

	apt-get install mkpasswd
        echo -e "$cyan##### Deleting user: $user #####$endColor"
	userdel -r $user

	echo -e "$cyan##### Adding the user: $user #####$endColor"
	adduser --system $user  --uid 550  --ingroup admin
	usermod -p `mkpasswd $passwd` $user

	echo -e "$cyan##### Adding wheel group to sudo #####$endColor"
	sed '/^#.*%admin\tALL=(ALL)\tALL.*/ s/^#//' /etc/sudoers > tmp
	cat tmp > /etc/sudoers
	echo -e "$cyan==================== User $user created successfully ====================$endColor"
}

####################################################################
# Profile USER
####################################################################
profileUser(){
	echo $userProfile > tmp
	cat tmp >> /home/$user/.bashrc
	source /home/$user/.bashrc
	echo -e "$cyan==================== Bash Profile to User $user created ====================$endColor"
	echo $rootProfile > tmp
	cat tmp >> /root/.bashrc
	source /root/.bashrc
	echo -e "$cyan==================== Bash Profile to User root created ====================$endColor"
}

####################################################################
# Update and Install Apache, PHP, MySQL, Django, Subversion, TRAC
####################################################################
updateInstall(){
	echo -e "$cyan======= Updating and Installing Apache, PHP, MySQL, SQLite, Django, Subversion ======$endColor"

	echo -e "$cyan##### Updating Operating System... #####$endColor" 
	apt-get -y update
	apt-get -y upgrade
	echo -e "$cyan================ System Updated successfully ================$endColor"
	
	apt-get -y install apache2 
	apt-get -y install mysql-server-5.1 libapache2-mod-auth-mysql
	apt-get -y install php5 libapache2-mod-php5 php5-mysql php5-cli php5-common php5-mcrypt php5-gd 
	apt-get -y install python-mysqldb libapache2-mod-python python-django python-setuptools
	apt-get -y install subversion sqlite

	#wget  http://www.djangoproject.com/download/1.1.1/tarball/
	#tar xzvf Django-1.1.1.tar.gz
	#cd Django-1.1.1
	#python setup.py install
	#cd ../
	#rm -rf Django-1.1.1*

	echo -e "$cyan================ Packages Installed successfully ================$endColor"
}

####################################################################
# Install TRAC
####################################################################
InstallTrac(){

	echo -e "$cyan##### Trac Install #####$endColor"  
	sudo easy_install Trac

	echo -e "$cyan##### Trac Plugins Install #####$endColor" 
	easy_install TracAccountManager TracProjectMenu
	echo -e "$cyan================ Trac Installed successfully ================$endColor"
}

####################################################################
# Create VirtualHosts
####################################################################
CreateVirtualHosts(){
	echo -e "$cyan============================= Creating VirtualHosts ================================$endColor"
	
	echo -e "$cyan#####    Reset Folders @ Apache  #####$endColor"
	rm -rf /var/www/svn /var/www/trac /var/www/html /var/www/logs
	rm -rf /etc/apache2/sites-available/0*
	rm -rf /etc/apache2/sites-enabled/0*
	mkdir -p /var/www/svn /var/www/trac /var/www/html /var/www/logs


	echo -e "$cyan=============================== Folders permission ==================================$endColor"
	chown -R www-data:$user /var/www/trac/ /var/www/svn/ /var/www/html/ /var/www/logs/ /var/www/phpmyadmin/
	chmod -R 755 /var/www/trac/ /var/www/svn/ /var/www/html/ /var/www/logs/ /var/www/phpmyadmin/

	echo -e "$cyan=============================== HTTPD Restart ==================================$endColor"
	sudo service apache2 start 
}
