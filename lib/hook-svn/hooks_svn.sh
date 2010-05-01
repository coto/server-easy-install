# Install SVN 1.6.9 
echo -e "$cyan##### We're updating Subversion to 1.5+, because it's neccesary to send email' #####$endColor" 
yum info subversion | grep '^Version' | awk '{ print $3 }'

rpm -Uhv http://apt.sw.be/redhat/el5/en/i386/rpmforge/RPMS/rpmforge-release-0.5.1-1.el5.rf.i386.rpm
yum -y update subversion mod_dav_svn
rpm -e rpmforge-release

REPO="newsite"

rm -rf /var/www/html/$REPO
sudo svn co file:////var/www/svn/$REPO/trunk /var/www/html/$REPO
sudo chown apache:apache -R /var/www/html/$REPO
sudo chmod 775 -R  /var/www/html/$REPO

echo "
#!/bin/sh
REPO=\"$REPO\"

REPOS=\"\$1\"
REV=\"\$2\"
AUTH=$(svnlook author \$REPOS -r \$REV)
TRAC_ENV=\"/var/www/trac/public/newsite\"
MAILER_CONF=\"/var/www/svn/\$REPO/hooks/mailer.conf\"

DATE=$(date +%Y%m%d-%H%M%S)

# LOG
echo -e \"\$DATE\\t\$AUTH\\t\$REPOS\\t\$REV\" >> /var/www/logs/svn-commits.log

# UPDATE SVN testing environment
svn update file:////var/www/svn/\$REPO/trunk /var/www/html/\$REPO
chown apache:apache -R /var/www/html
chmod 755 -R /var/www/html

# TRAC post commit
/usr/bin/python /var/www/svn/hooks-global/trac-post-commit-hook.py \
-p \"\$TRAC_ENV\" -r \"\$REV\"

# MAILER
/usr/bin/python /var/www/svn/hooks-global/mailer.py commit \"\$REPOS\" \"\$REV\" \"\$MAILER_CONF\"

" > /var/www/svn/public/$REPO/hooks/post-commit
cp -f ./files/mailer.conf /var/www/svn/public/$REPO/hooks/mailer.conf
cp -rf ./files/hooks-global/ /var/www/svn/public/
chmod u+x /var/www/svn/public/$REPO/hooks/post-commit

/etc/init.d/httpd restart
