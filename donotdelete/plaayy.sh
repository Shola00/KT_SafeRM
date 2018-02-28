#!/bin/bash
#this is a sample of my saferm script
#create a .Trash_SafeRm if it doesn't exist

homeDir="$HOME"
trashSafermDirName=".Trash_saferm"
safeRmPath="$HOME/$trashSafermDirName"
numberOfItemsInDirectory=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)

vFlag=0
rFlag=0
dFlag=0

vArg1=""
rArg1=""
dArg1=""


function usage(){

echo " usage : $0 [-v <option>][-r <option> ] [-d <option> ]"

}

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
  if [[ -f $1 ]] && [[ $numberOfItemsInDirectory -eq 0 ]]; then
      read -p "remove $1 ? " response
      userReplyYes $response
      if [[ ($? -eq 0) ]] ; then
          # mv $currentDir $safeRmPath
          echo "$1 removed"
      else
          echo "$1 not removed"
      fi
  fi
}

handleEmptyDir(){
  if [[ -d $1 ]] && [[ $numberOfItemsInDirectory -eq 0 ]]; then
      read -p "remove $1 ? " response
      userReplyYes $response
      if [[ ($? -eq 0) ]] ; then
          # mv $currentDir $safeRmPath
          echo "$1 removed"
      else
          echo "$1 not removed"
      fi
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

    if [[ -d $currentDir ]] ; then
        read -p "remove $currentDir? " response
        finalSafeRm $currentDir
    else
        handleFile $currentDir
    fi


    currentDir=$(dirname $currentDir)

}


recursiveRm(){

    if [[ -d "$1" ]] && [[ $numberOfItemsInDirectory -gt 0 ]]; then
            read -p "examine files in $1? " response
            userReplyYes $response
                if [[ ($? -eq 0) ]] ; then
                        recursivelyExamineSubDirectory $1
                else
                    echo "$1 not examined"
                    read -p "remove $1? " response
                    userReplyYes $response
                    if [[ ($? -eq 0) ]] ; then
                      echo "$1 not empty"
                    else
                      false
                    fi
                fi
    else
        false
    fi
}

while getopts ":v:r:d:" opt ; do
    case $opt in
        v)
            vFlag=1;
            vArg1=$OPTARG
            ;;
        r)
            rFlag=1;
            rArg1=$OPTARG
            ;;
        d)
            dFlag=1;
            dArg1=$OPTARG
            ;;
        *)
        usage
        echo "Invalid argument"
    esac
done

shift $((OPTIND-1))


if [ ! -d "$safeRmPath" ];
then
  mkdir "$safeRmPath"
fi
#if [[ ($dFlag -eq 1) ]]; then
#echo "safeRm: $dArg1 directory not empty"
#fi

# if [[ ($rFlag -eq 1) ]] || [[ ($rFlag -eq 0) ]]; then
recursiveRm $1
# fi

# if [[ ($vFlag -eq 1) ]] || [[ ($dFlag -eq 1) ]] || [[ ($vFlag -eq 0) ]] || [[ ($dFlag -eq 0) ]] ; then
  handleFile $1
  handleEmptyDir $1

#fi

