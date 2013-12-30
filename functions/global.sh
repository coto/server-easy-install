
####################################################################
# Configurating SSH and IPTABLES
####################################################################
sshIptables(){
	echo -e "$cyan====================== Configurating SSH and IPTABLES  =========================$endColor"

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
	#  Allows all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT
	#  Accepts all established inbound connections
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	#  Allows all outbound traffic
	iptables -A OUTPUT -j ACCEPT
	# Allows HTTP and HTTPS connections from anywhere (the normal ports for websites)
	iptables -A INPUT -p tcp --dport 80 -j ACCEPT
	iptables -A INPUT -p tcp --dport 443 -j ACCEPT
	iptables -A INPUT -p tcp --dport 21 -j ACCEPT 
	#  Allows SSH connections
	iptables -A INPUT -p tcp -m state --state NEW --dport $port -j ACCEPT
	# Add VNC Port 5900
	# iptables -A INPUT -p tcp -m state --state NEW --dport 5900 -j ACCEPT
	# Allow ping
	iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

	# log iptables denied calls
	iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

	# Reject all other inbound - default deny unless explicitly allowed policy
	iptables -A INPUT -j REJECT
	iptables -A FORWARD -j REJECT

	echo -e "$cyan##### IPTABLES & SSH RELOAD #####$endColor"
	#sudo /etc/init.d/iptables save
	/sbin/iptables-save

	sudo $ssh_service reload
	echo -e "$cyan=============== SSH & IPTABLES setted successfully ===============$endColor"
}

####################################################################
# Configure and securitizing Apache
####################################################################
secureApache(){
	echo -e "$cyan====================== Configure and securitizing Apache ==========================$endColor"

	echo -e "$cyan#####    Reset Folders @ Apache in $apache_conf #####$endColor"
	rm -rf /var/www/passwd

	echo -e "$cyan#####    passwd Apache setup   #####$endColor"
	mkdir -p /var/www/passwd
	htpasswd -cb /var/www/passwd/.htpasswd $user $passwd
	# htpasswd -b /var/www/passwd/.htpasswd another_user $passwd
	chown -R $apache_user:$apache_user /var/www/passwd/
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
	echo -e "$cyan================ Apache was securitize successfully ===============$endColor"
}

####################################################################
# Configure and securitizing MySQL
####################################################################
secureMySQL(){
	echo -e "$cyan======================= Configure and securitizing MySQL ==========================$endColor"

	echo -e "$cyan##### Start mysqld  #####$endColor"
	service $mysql_service start

	echo -e "$cyan##### Reset mysqld #####$endColor"
	MySQLRestore=/var/mysql.dump
	if [ -f $MySQLRestore ];
	then
	    echo "File $MySQLRestore exists"
	    echo -e "$cyan##### Restore mysql Database #####$endColor" 
	    mysql -u $user -p$passwd mysql < /var/mysql.dump
	    service $mysql_service restart
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

	service $mysql_service restart
	echo -e "$cyan==================== MySQL was securitize successfully ===============$endColor"
}

####################################################################
# Trac and SVN configuration
####################################################################
tracsvn(){
	echo -e "$cyan=========================== TRAC & SVN Config ===============================$endColor"

	echo -e "$cyan How many projects do you want?$endColor"
	read nprojects

	for i in `seq 1 $nprojects` 
	do
		echo -e "$cyan Project Name for number $i : $endColor"
		read project_name 

		echo -e "$cyan What database do you want?$endColor"
		echo -e "\t$cyan 1) mySQL$endColor"
		echo -e "\t$cyan 2) SQLite$endColor"

		read dbtrac;
		while [[ $dbtrac -gt 2 || ! $(echo $dbtrac | grep '^[1-9]') ]]
		do
			echo -e "$red Error: You must to choose an option $endColor"
			read dbtrac
		done

		# SVN
		sudo mkdir -p /var/www/svn/$project_name 
		sudo mkdir -p /tmp/newsvn
		sudo mkdir -p /tmp/newsvn/$project_name/{trunk,tags,branches} 
		sudo svnadmin create /var/www/svn/$project_name --fs-type fsfs

		sudo svn import /tmp/newsvn/$project_name file:///var/www/svn/$project_name -m "Initial import" 
		sudo rm -rf /tmp/newsvn
		sudo chown -R $apache_user:$apache_user /var/www/svn/$project_name
		sudo chmod -R go-rwx /var/www/svn/$project_name

		if [[ $dbtrac = "1" ]]; then
			####################################################################	
			#TRAC w/MySQL (It uses $PassTrac)
			####################################################################	
			sudo mysql -u$user -p$passwd -e "CREATE DATABASE trac_$project_name; GRANT ALL ON trac_$project_name.* TO '$user'@'localhost' IDENTIFIED BY \"$passwd\";"
			sudo trac-admin /var/www/trac/public/$project_name initenv $project_name mysql://$user:$passwd@localhost:3306/trac_$project_name svn /var/www/svn/$project_name
		else
			####################################################################	
			# Trac w/SQLite
			####################################################################
			sudo mkdir -p /var/www/trac/public/$project_name
			sudo trac-admin /var/www/trac/public/$project_name initenv $project_name sqlite:db/trac.db svn /var/www/svn/$project_name
		fi
		
		sudo mkdir -p /var/www/trac/public
		sudo chown -R $apache_user:$apache_user /var/www/trac/public/$project_name 
		sudo chmod -R o-rwx /var/www/trac/public/$project_name
		sudo chmod g+w /var/www/trac/public/$project_name/conf/trac.ini

		sudo trac-admin /var/www/trac/public/$project_name permission add $user TRAC_ADMIN
	
		echo -e "$cyan#####    Getting TRAC Logo   #####$endColor"

		wget http://www.edgewall.org/gfx/trac_logo.png
		sudo mv ./trac_logo.png /var/www/trac/public/$project_name/htdocs/your_project_logo.png

		sudo echo "

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
		echo -e "$cyan====== Project $project_name on TRAC/SVN created successfully ======$endColor"
	done
}
