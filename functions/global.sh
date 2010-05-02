
####################################################################
# Configurating SSH and IPTABLES
####################################################################
sshIptables(){
	echo -e "$cyan\n====================== Configurating SSH and IPTABLES  =========================$endColor"

	if [ ! -f /etc/ssh/sshd_config.orig ]; then
		cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
	fi
	echo -e "$cyan##### SSH: Add Port $port #####$endColor"
	sed "/^#Port 22.*/ s/^#Port 22/Port $port/" /etc/ssh/sshd_config > tmp
	cat tmp > /etc/ssh/sshd_config
	sed '/^#PermitRootLogin yes.*/ s/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config > tmp
	cat tmp > /etc/ssh/sshd_config
	sed '/^#X11Forwarding no.*/ s/^#//' /etc/ssh/sshd_config > tmp
	cat tmp > /etc/ssh/sshd_config

	echo -e "$cyan##### IPTABLES RULES #####$endColor"
	iptables -F
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A INPUT -i ! lo -d 127.0.0.0/8 -j REJECT
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables -A OUTPUT -j ACCEPT
	iptables -A INPUT -p tcp --dport 80 -j ACCEPT
	iptables -A INPUT -p tcp --dport 443 -j ACCEPT
	iptables -A INPUT -p tcp --dport 21 -j ACCEPT 
	iptables -A INPUT -p tcp -m state --state NEW --dport $port -j ACCEPT
	# Add VNC Port 5900
	# iptables -A INPUT -p tcp -m state --state NEW --dport 5900 -j ACCEPT
	iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
	iptables -A INPUT -j REJECT
	iptables -A FORWARD -j REJECT

	echo -e "$cyan##### IPTABLES & SSH RELOAD #####$endColor"
	sudo /etc/init.d/iptables save
	sudo /etc/init.d/sshd reload
}
####################################################################
# Configure and securitizing Apache
####################################################################
secureApache(){
	echo -e "$cyan\n====================== Configure and securitizing Apache ==========================$endColor"

	echo -e "$cyan#####    Reset Folders @ Apache  #####$endColor"
	rm -rf /var/www/passwd

	echo -e "$cyan#####    passwd Apache setup   #####$endColor"
	mkdir -p /var/www/passwd
	htpasswd -cb /var/www/passwd/.htpasswd $user $passwd
	# htpasswd -b /var/www/passwd/.htpasswd another_user $passwd
	chown -R apache:apache /var/www/passwd/
	chmod 644 /var/www/passwd/.htpasswd

	echo -e "$cyan##### httpd.conf modified #####$endColor"
	if [ ! -f $apache_conf.orig ]; then
		cp -f $apache_conf $apache_conf.orig
	fi
	sed "/^#ServerName www.example.com:80.*/ s/^#ServerName www.example.com:80/ServerName *:80/" $apache_conf > tmp
	cat tmp > $apache_conf
	sed "/^ServerAdmin root\@localhost.*/ s/^ServerAdmin root\@localhost/ServerAdmin $mailAdmin/" $apache_conf > tmp
	cat tmp > $apache_conf
	sed "/^Timeout 120.*/ s/^Timeout 120/Timeout 40/" $apache_conf > tmp
	cat tmp > $apache_conf
	sed "/^KeepAlive Off.*/ s/^KeepAlive Off/KeepAlive On/" $apache_conf > tmp
	cat tmp > $apache_conf
	sed "/^MaxKeepAliveRequests 100.*/ s/^MaxKeepAliveRequests 100/MaxKeepAliveRequests 200/" $apache_conf > tmp
	cat tmp > $apache_conf
	sed "/^KeepAliveTimeout 15.*/ s/^KeepAliveTimeout 15/KeepAliveTimeout 3/" $apache_conf > tmp
	cat tmp > $apache_conf
	sed "/^ServerTokens OS.*/ s/^ServerTokens OS/ServerTokens Prod/" $apache_conf > tmp
	cat tmp > $apache_conf
	sed "/^ServerSignature On.*/ s/^ServerSignature On/ServerSignature Off/" $apache_conf > tmp
	cat tmp > $apache_conf
}
####################################################################
# Configure and securitizing MySQL
####################################################################
secureMySQL(){
	echo -e "$cyan\n======================= Configure and securitizing MySQL ==========================$endColor"

	echo -e "$cyan##### Start mysqld  #####$endColor"
	sudo /etc/init.d/mysqld start

	echo -e "$cyan##### Reset mysqld #####$endColor"
	MySQLRestore=/var/mysql.dump
	if [ -f $MySQLRestore ];
	then
	    echo "File $MySQLRestore exists"
	    echo -e "$cyan##### Restore mysql Database #####$endColor" 
	    mysql -u $user -p$passwd mysql < /var/mysql.dump
	    sudo /etc/init.d/mysqld restart
	else
	    echo "File $MySQLRestore does not exists"
	    echo -e "$cyan##### Backup mysql Database #####$endColor" 
	    mysqldump mysql > $MySQLRestore
	fi
	echo -e "$cyan##### Set root mysql password #####$endColor"
	mysqladmin -u root password "$passwd"

	echo -e "$cyan##### Deleting All databases Mysql, except mysql & information_schema #####$endColor"
	DATABASES=$(mysql -u root -p$passwd -h localhost  -e 'show databases' | awk '{ print $1}' | grep -v '^Database' | grep -v '^mysql' | grep -v '^information_schema')
	for t in $DATABASES
	do
		echo "Deleting $t database..."
		mysql -u root -p$passwd -h localhost -e "drop database $t"
		#echo "drop database $t; flush privileges;" | mysql -u root -p$passwd mysql
		#mysqladmin -u root drop -f $t
	done

	echo -e "$cyan##### Deleting others users #####$endColor"
	echo "delete from db; delete from user where not (host=\"localhost\" and user=\"root\"); flush privileges;" | mysql -u root -p$passwd mysql
	echo -e "$cyan##### Changing root name #####$endColor"
	echo "update user set user=\"$user\" where user=\"root\"; flush privileges;" | mysql -u root -p$passwd mysql

	echo -e "$cyan##### Remove history MySql #####$endColor" 
	cat /dev/null > ~/.mysql_history

	sudo /etc/init.d/mysqld restart
}
####################################################################
# Trac and SVN configuration
####################################################################
tracsvn(){
	echo -e "$cyan\n=========================== TRAC & SVN Config ===============================$endColor"

	echo -e "$cyan How many projects do you want?$endColor"
	read nprojects

	#echo -e "$cyan#####    Create Trac User Mysql   #####$endColor"
	#mysql -u$user -p$passwd -e "CREATE USER 'user_trac'@'localhost' IDENTIFIED BY \"$passwd\"; "

	for i in `seq 1 $nprojects` 
	do
		echo -e "$cyan Project Name for number $i : $endColor"
		read project_name 

		# SVN
		mkdir -p /var/www/svn/$project_name 
		mkdir -p /tmp/newsvn
		mkdir -p /tmp/newsvn/$project_name/{trunk,tags,branches} 
		svnadmin create /var/www/svn/$project_name --fs-type fsfs

		svn import /tmp/newsvn/$project_name file:///var/www/svn/$project_name -m "Initial import" 
		rm -rf /tmp/newsvn
		chown -R apache:apache /var/www/svn/$project_name
		chmod -R go-rwx /var/www/svn/$project_name

		####################################################################	
		#TRAC w/MySQL (It uses $PassTrac)
		####################################################################	
		#mysql -u$user -p$passwd -e "CREATE DATABASE trac_$project_name; GRANT ALL ON trac_$project_name.* TO 'user_trac'@'localhost' IDENTIFIED BY \"$PassTrac\";"
		#trac-admin /var/www/trac/public/$project_name initenv $project_name mysql://user_trac:$PassTrac@localhost:3306/trac_$project_name svn /var/www/svn/$project_name

		####################################################################	
		# Trac w/SQLite
		####################################################################
		mkdir -p /var/www/trac/public/$project_name
		trac-admin /var/www/trac/public/$project_name initenv $project_name sqlite:db/trac.db svn /var/www/svn/$project_name

		chown -R apache:apache /var/www/trac/public/$project_name 
		chmod -R o-rwx /var/www/trac/public/$project_name
		chmod g+w /var/www/trac/public/$project_name/conf/trac.ini

		trac-admin /var/www/trac/public/$project_name permission add $user TRAC_ADMIN
	
		echo -e "$cyan#####    Getting TRAC Logo   #####$endColor"

		wget http://www.edgewall.org/gfx/trac_logo.png
		mv ./trac_logo.png /var/www/trac/public/$project_name/htdocs/your_project_logo.png

	echo "

	[ticket-custom]
	complete = select
	complete.label = % Complete
	complete.options = 0|5|10|15|20|25|30|35|40|45|50|55|60|65|70|75|80|85|90|95|100
	complete.order = 3
	due_assign = text
	due_assign.label = Start (YYYY/MM/DD)
	due_assign.order = 1
	due_close = text
	due_close.label = End (YYYY/MM/DD)
	due_close.order = 2
	" >> /var/www/trac/public/$project_name/conf/trac.ini

	done
}
