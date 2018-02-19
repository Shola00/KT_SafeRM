#!/bin/bash
#this is a sample of my saferm script
#create a .Trash_SafeRm if it doesn't exist

homeDir="$HOME"
trashSafermDirName=".Trash_saferm"
trashSafermPath="$home/$trashSafermDirName"
target=$1

if [ ! -d "$HOME/.Trash_saferm" ];
then
        mkdir "$HOME/.Trash_saferm"
fi

#saferm for directory
if [[ -f "$1" ]]
then
        echo "$1 is a file"
elif [[ -d "$1" ]]
then
        echo "$1 is a directory"
fi

read -p "remove $1? " -n 2 -r
if [[ ${response:0:1} == 'y' || ${response:0:1} == 'Y' ]] && find "$target" -mindepth 1 -print -quit | grep -q .;
then
	echo "$target not empty"
	read -p "examine files in $1? " -n 2 -r		
	#mv $1 $HOME/.Trash_saferm
fi

#check if a directory is empty
#if find "$target" -mindepth 1 -print -quit | grep -q .;
#then
	#echo "$target not empty"
#fi
