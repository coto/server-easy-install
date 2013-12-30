#!/bin/bash
####################################################################
# Generate a public/private key
# Author: Coto Augosto C.
# URL: http://beecoss.com
# Created: Mar 5, 2010
####################################################################

user=$1
port=$2

if [ "$user" = "" ]; then
    user="root"
fi
if [ "$port" = "" ]; then
    port="22"
fi
if [ "$user" = "root" ]; then
    folder="root"
else
    folder="home/$user"
fi

####################################################################
# Define Distro
####################################################################

echo "Insert the IP of server where you want to upload public key"
read ip

while [[ ! $distro =~ ^1|2$ ]]; do
	echo "Choose a option's number [1] RHEL, [2] CentOs:"
	read ip
done

####################################################################
# Define Distro
####################################################################

mkdir -p ~/.ssh
ssh-keygen -t rsa
scp -P $port ~/.ssh/id_rsa.pub $user@$ip:/$folder/
echo "==================================================================="
echo "=============               Local Key               ==============="
echo "==================================================================="
cat ~/.ssh/id_rsa.pub
echo "==================================================================="
echo "=============                 Remote                ==============="
echo "==================================================================="
echo -e "Put this on remote:\n\t
		mkdir -p /$folder/.ssh; mv -f /$folder/id_rsa.pub /$folder/.ssh/authorized_keys; chown -R $user:$user /$folder/.ssh; chmod 700 /$folder/.ssh; chmod 600 /$folder/.ssh/*;"
echo -e "\n\tcat /$folder/.ssh/authorized_keys"
echo "==================================================================="
ssh -p $port $user@$ip
