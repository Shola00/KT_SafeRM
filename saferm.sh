#!/bin/bash
#this is a sample of my saferm script
#create a .Trash_SafeRm if it doesn't exist

homeDir="$HOME"
trashSafermDirName=".Trash_saferm"
safeRmPath="$HOME/$trashSafermDirName"
numberOfItemsInDirectory=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)

if [ ! -d "$safeRmPath" ];
then
mkdir "$safeRmPath"
fi

finalSafeRm(){

userReplyYes $response
if [[ ($? -eq 0) ]] && [[ $numberOfItemsInDirectory -eq 0 ]]
then
echo "$currentDir removed"
#mv $currentDir $safeRmPath
else
echo "$currentDir not removed"
fi
}

userReplyYes(){
responseFirstLetter=$( echo "$1" | head -c 1)
if [[ $responseFirstLetter == 'y' || $responseFirstLetter == 'Y' ]];
then
true
else
false
fi

}

handleFile(){

read -p "remove $1? " response
userReplyYes $response
if [[ ($? -eq 0) ]]; then
echo "$1 removed"
# mv $currentDir $safeRmPath
else
echo "$1 not removed"
fi

}

recursivelyExamineSubDirectory(){

currentDir=$1
itemsInDirectories=$(ls -l "$currentDir" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d')
for item in $itemsInDirectories; do
numberOfContentsInDirectory=$(ls -l "$currentDir/$item" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)

#for directories
if [[ -d "$currentDir/$item" ]]; then
read -p "examine files in $currentDir/$item? " response

userReplyYes $response
#examine contents in subdirectory
if [[ ($? -eq 0) ]] && [[ $numberOfContentsInDirectory -eq 0 ]]; then
read -p "remove $currentDir/$item? " response
userReplyYes $response
if [[ ($? -eq 0) ]]; then
echo "$currentDir/$item removed"
#mv $currentDir/$item $safeRmPath
else
echo "$currentDir/$item not removed"
fi
fi

userReplyYes $response
if [[ ($? -eq 0) ]] && [[ $numberOfContentsInDirectory -gt 0 ]]; then
recursivelyExamineSubDirectory $currentDir/$item

fi

else
read -p "remove $currentDir/$item? " response
userReplyYes $response
if [[ ($? -eq 0) ]]; then
echo "$currentDir/$item removed"
# mv $currentDir/$item $safeRmPath
else
echo "$currentDir/$item not removed"
fi
fi

done

if [[ -d $currentDir ]]; then
read -p "remove $currentDir? " response
finalSafeRm $currentDir
else
handleFile $currentDir
fi

currentDir=$(dirname $currentDir)

}

if [[ -d "$1" ]] && [[ $numberOfItemsInDirectory -gt 0 ]]; then
read -p "examine files in $1? " response
userReplyYes $response
if [[ ($? -eq 0) ]]; then
recursivelyExamineSubDirectory $1
else
echo "$1 not examined"
fi

else
handleFile $1
fi


