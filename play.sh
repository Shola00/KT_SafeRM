#!/bin/bash
#playing with codes before applying them

userReplyYes(){
    responseFirstLetter=$( echo "$1" | head -c 1)
    if [[ $responseFirstLetter == 'y' || $responseFirstLetter == 'Y' ]];
    then
        true
    else
        false
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
            else
                echo "$currentDir/$item not removed"
            fi
    fi
done

read -p "remove $currentDir? " response
userReplyYes $response
if [[ ($? -eq 0) ]]
then
    echo "$currentDir removed"
else
    echo "$currentDir not removed"
fi

currentDir=$(dirname $currentDir)

}

recursivelyExamineSubDirectory $1


