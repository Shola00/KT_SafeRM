#!/bin/bash
#playing with codes before applying them

itemsInDirectories=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d')

userReplyYes(){
    responseFirstLetter=$( echo "$1" | head -c 1)
    if [[ $responseFirstLetter == 'y' || $responseFirstLetter == 'Y' ]];
    then
        true
    else
        false
    fi
}

examineSubDirectory(){


for item in $itemsInDirectories; do
numberOfContentsInDirectory=$(ls -l "$1/$item" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)

    #for directories
    if [[ -d "$1/$item" ]]; then
        read -p "examine files in $1/$item? " response
        userReplyYes $response
        #examine contents in subdirectory

            if [[ ($? -eq 0) ]] && [[ $numberOfContentsInDirectory -eq 0 ]]; then
                read -p "remove $1/$item? " response
                userReplyYes $response
                    if [[ ($? -eq 0) ]]; then
                        echo "$1/$item removed"
                    else
                        echo "$1/$item not removed"
                    fi
            fi
            if [[ ($? -eq 0) ]] && [[ $numberOfContentsInDirectory -gt 0 ]]; then
                    #[[ ($? -eq 0) ]]; then
                echo "$1/$item not empty"
                read -p "examine files in $1/$item" response
                userReplyYes $response
                    if [[ ($? -eq 0) ]]; then
                        examineSubDirectory $1/$item
                    else
                        echo "not examined"
                    fi
            fi
    else
        read -p "remove $1/$item? " response
        userReplyYes $response
            if [[ ($? -eq 0) ]]; then
                echo "$1/$item removed"
            else
                echo "$1/$item not removed"
            fi
    fi
done

}

examineSubDirectory $1


