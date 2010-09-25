#!/bin/bash
echo "Updating Sandbox..."
sandbox_dir=`pwd`
dir=`ls $sandbox_dir`
for d in $dir
do	
	if [ -d $sandbox_dir/$d/.svn ];
	then
		cd $sandbox_dir/$d
		echo -e "\033[4m$d (svn)\e[0m"
		svn update
	elif [ -d $sandbox_dir/$d/.git ];
	then
		cd $sandbox_dir/$d
		echo -e "\033[4m$d (git)\e[0m"
		git pull origin master 
	fi
done
echo "Sandbox Updated Successfully!"
