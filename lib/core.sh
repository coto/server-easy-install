#!/bin/sh

cyan='\e[1;37;44m'
red='\e[1;31m'
endColor='\e[0m'
datetime=$(date +%Y%m%d%H%M%S)

lowercase(){
	echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

####################################################################
# Get infor about system
####################################################################
shootProfile(){
	OS=`lowercase \`uname\``
	KERNEL=`uname -r`
	MACH=`uname -m`

	if [ "{$OS}" == "windowsnt" ]; then
		OS=windows
	elif [ "{$OS}" == "darwin" ]; then
		OS=mac
	else
		OS=`uname`
		if [ "${OS}" = "SunOS" ] ; then
			OS=Solaris
			ARCH=`uname -p`
			OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
		elif [ "${OS}" = "AIX" ] ; then
			OSSTR="${OS} `oslevel` (`oslevel -r`)"
		elif [ "${OS}" = "Linux" ] ; then
			if [ -f /etc/redhat-release ] ; then
				DistroBasedOn='RedHat'
				DIST=`cat /etc/redhat-release |sed s/\ release.*//`
				PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/SuSE-release ] ; then
				DistroBasedOn='SuSe'
				PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
				REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
			elif [ -f /etc/mandrake-release ] ; then
				DistroBasedOn='Mandrake'
				PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/debian_version ] ; then
				DistroBasedOn='Debian'
				DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
				PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
				REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
			fi
			if [ -f /etc/UnitedLinux-release ] ; then
				DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
			fi
			OS=`lowercase $OS`
			DistroBasedOn=`lowercase $DistroBasedOn`
		 	readonly OS
		 	readonly DIST
			readonly DistroBasedOn
		 	readonly PSUEDONAME
		 	readonly REV
		 	readonly KERNEL
		 	readonly MACH
		fi

	fi
}
shootProfile
#echo "OS: $OS"
#echo "DIST: $DIST"
#echo "PSUEDONAME: $PSUEDONAME"
#echo "REV: $REV"
#echo "DistroBasedOn: $DistroBasedOn"
#echo "KERNEL: $KERNEL"
#echo "MACH: $MACH"
#echo "========"


####################################################################
# Get Distro Based on... (Deprecated)
####################################################################
get_DistroBasedOn(){
	if [[ ! $OS = "linux" ]]; then
		echo "hol"
		return
	fi
	regExpLsbFile="/etc/(.*)[-_]"

	etcFiles=`ls /etc/*[-_]{release,version} 2>/dev/null`
	for file in $etcFiles; do
	  if [[ $file =~ $regExpLsbFile ]]; then
		 DistroBasedOn=${BASH_REMATCH[1]}
		 echo ${BASH_REMATCH[1]}
		 break
	  else
		 echo "??? Should not occur: Don't find any etcFiles ???"
		 exit 1
	  fi
	done

	DistroBasedOn=`lowercase $DistroBasedOn`

	case $DistroBasedOn in
		suse) 	DistroBasedOn="opensuse" ;;
		linux)	DistroBasedOn="linuxmint" ;;
	esac

	readonly DistroBasedOn
}
#get_DistroBasedOn
#echo $DistroBasedOn

####################################################################
# Print Menu
####################################################################
printMenu(){
	if [[ "$user" = "" || "$passwd" = "" || "$port" = "" ]]; then
		echo -e "$red Error: USER, PASS AND PORT ARE REQUIRED, PLEASE SET THEM IN CONFIG FILE $endColor"
		echo ""
		echo ""
		exit 1 
	fi
	clear
	echo -e "$cyan Fast and Easy Web Server Installation $endColor"
	echo "What do you want to do?"
	echo -e "\t1) Create or create again the $user user"
	echo -e "\t2) Create users profile (color in bash)"
	echo -e "\t3) Update and Install (Apache, PHP, MySQL, SQLite, Django, Subversion)"
	echo -e "\t4) Configurating SSH and IPTABLES"
	echo -e "\t5) Configure and securitizing Apache"
	echo -e "\t6) Configure and securitizing MySQL"
	echo -e "\t7) Create SVN & TRAC repos"
	echo -e "\t8) Create a Mail Server"
	echo -e "\t9) Create a cron backup (mysql, apache, trac & svn)"
	echo -e "\t10) Set DNS and to add Google Apps MX records (Only SliceHost.com)"
	echo -e "\t11) Install Trac and its Plugins"
	echo -e "\t12) I do not know, exit!"
	#echo -e "\t13) Create VirtualHosts"
	read option;
	while [[ $option -gt 12 || ! $(echo $option | grep '^[1-9]') ]]
	do
		printMenu
	done
	runOption
}
####################################################################
# Run an Option
####################################################################
runOption(){
	case $option in
		1) createUser;;
		2) profileUser;;
		3) updateInstall;;
		4) sshIptables;;
		5) secureApache;;
		6) secureMySQL;;
		7) tracsvn;;
		8) mailServer;;
		9) cronBackup;;
		10) set_dns;;
		11) InstallTrac;;
		12) exit
#		13) CreateVirtualHosts;;
	esac 
	echo "Press any Key to continue"
	read x
	printMenu
}


