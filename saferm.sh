#!/bin/bash
#this is a sample of my saferm script
#create a .Trash_SafeRm if it doesn't exist

homeDir="$HOME"
trashSafermDirName=".Trash_saferm"
Path="$HOME/$trashSafermDirName"
target=$1
itemsInDirectories=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | xargs)

userReplies(){

[[ ${reply} == 'y*' || ${reply} == 'Y*' ]]

}


if [ ! -d "$Path" ];
then
        mkdir "$Path"
fi

#saferm for directory
if [[ -f "$1" ]]
then
        echo "$1 is a file"
elif [[ -d "$1" ]]
then
        echo "$1 is a directory"
fi

if [[ -d "$1" ]] || [[ -f "$1" ]] && [[ $# -ne 0 ]]
then 
	#if its a file or directory and the number of argument isn't zero 
	read -p "remove $1? "
	if [[ userReplies ]] && find "$target" -mindepth 1 -print -quit | grep -q .;
	then

		echo "$target not empty"		
		read -p "examine $1? "
		if [[ userReplies ]];
		then
			for i in $itemsInDirectories; do

        		read -p "remove $i? :"
        		echo "$i removed"
			done

		else
			false
		fi	
	else
		false
		
	fi
else
	echo "usage: saferm [-f | -i] [-dPRrvW] file ..."
        echo " unlink file"

fi




	 
	#given the reply is yes

#check if a directory is empty
	#checkingMindepth=$(find "$target" -mindepth 1 -print -quit | grep -q)

	#echo "$target not empty"
#fi
