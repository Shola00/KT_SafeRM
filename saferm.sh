#!/bin/bash
#this is a sample of my saferm script
#create a .Trash_SafeRm if it doesn't exist

homeDir="$HOME"
trashSafermDirName=".Trash_saferm"
Path="$HOME/$trashSafermDirName"

contentCount=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)

userReplyYes(){

responseFirstLetter=$( echo "$1" | head -c 1)
    if [[ $responseFirstLetter == 'y' || $responseFirstLetter == 'Y' ]];
    then
        true
    else
        false
    fi
}


if [ ! -d "$Path" ];
then
        mkdir "$Path"
fi

#saferm for directory

#if the user reply is yes, examine directory
    #get a list of the contents of the directory (get files and directory names)
    #while looping through the given directory, append the specific file name in the iteration onto the directory
#if the user reply is no, then do nothing
#look into the directory passed as an argument and check if it is empty
#if the directory is empty, the directory should be removed.
#if the directory is not empty, then loop through items in the directory
#if the curent iteration is a file then remove it

handleContentsOfDirectory(){
    if [[ -d $1/$item ]];
    then
        true
    else
        false
    fi
}

handleDirectories(){
    itemsInDirectories="$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d');"

    #prompt the user, asking if the user wants to examine the directory
read -p "do you want to examine files in $1?" response

    userReplyYes $response

    #if user response is yes or the result of the argument is equal to zero

    if [[ ($? -eq 0) ]];
    then
        #loop and iterate

        for item in $itemsInDirectories; do

            if [[ -d "$1/$item" ]]; then
                read -p "remove $1/$item? " response
                userReplyYes $response
                    if [[ ($? -eq 0) ]]; then
                        echo "$1/$item removed"
                    else
                        echo "$1/$item not removed"
                    fi
            else
                    read -p "remove $1 $item? " response
                    userReplyYes $response
                        if [[ ($? -eq 0) ]]; then
                            echo "$1 $item removed"
                        else
                            echo "$1 $item not removed"
                        fi
            fi
        done

        read -p "do you want to remove $1 ?" response
            userReplyYes $response
        if [[ $responseIsY ]] && [[ $contentCount -gt 0 ]];
        then
            echo "Directory not empty"
        else
            echo ""
        fi
    else
        echo "$1 not removed"
    fi
}

handleDirectories $1
