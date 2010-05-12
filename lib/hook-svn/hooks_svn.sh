echo "inckuded"
hooks_svn(){

	# Install SVN 1.6.9 
	echo -e "$cyan##### We're updating Subversion to 1.5+, because it's neccesary to send email' #####$endColor" 
	echo "This is your current version: "
	yum info subversion | grep '^Version' | awk '{ print $3 }'

	rpm -Uhv http://apt.sw.be/redhat/el5/en/i386/rpmforge/RPMS/rpmforge-release-0.5.1-1.el5.rf.i386.rpm
	yum -y update subversion mod_dav_svn
	rpm -e rpmforge-release

	svn_dir='/var/www/svn'
	dir=`ls $svn_dir`
	for d in $dir
	do	
		if [ -d $svn_dir/$d/hooks ];
		then
			echo -e "$cyan Installing Hook on $svn_dir/$d... $endColor"
			sudo echo "
			#!/bin/sh
			REPO=\"$d\"

			REP=\"\$1\"
			REV=\"\$2\"
			AUTH=\$(svnlook author \$REP -r \$REV)
			TRAC_ENV=\"/var/www/trac/public/\$REPO\"
			MAILER_CONF=\"/var/www/svn/\$REPO/hooks/mailer.conf\"

			DATE=\$(date +%Y%m%d-%H%M%S)

			# LOG
			echo -e \"\$DATE\\t\$AUTH\\t\$REP\\t\$REV\" >> /var/www/logs/svn-commits.log

			# UPDATE SVN testing environment
			# svn update file:////var/www/svn/\$REPO/trunk /var/www/html/\$REPO
			# chown apache:apache -R /var/www/html
			# chmod 755 -R /var/www/html

			# TRAC post commit
			/usr/bin/python /var/www/svn/hooks-global/trac-post-commit-hook.py \\
			-p \"\$TRAC_ENV\" -r \"\$REV\"

			# MAILER
			/usr/bin/python /var/www/svn/hooks-global/mailer.py commit \"\$REP\" \"\$REV\" \"\$MAILER_CONF\"

			" > /var/www/svn/$d/hooks/post-commit
			echo ".../var/www/svn/$d/hooks/post-commit created"
			cp -f $base_path/lib/hook-svn/files/mailer.conf /var/www/svn/$d/hooks/mailer.conf
			echo ".../var/www/svn/$d/hooks/mailer.conf created"
			sudo chmod u+x /var/www/svn/$d/hooks/post-commit
			echo "...Hook on /var/www/svn/$d/hooks/post-commit installed"
		fi
	done
	echo "Hooks were installed"

	sudo cp -rf $base_path/lib/hook-svn/files/hooks-global/ /var/www/svn/
	sudo chown apache:apache -R /var/www/svn
	sudo chmod 755 -R  /var/www/svn

	sudo /etc/init.d/httpd restart
}
