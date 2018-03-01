#!/bin/bash
#this is a sample of my saferm script
#create a .Trash_SafeRm if it doesn't exist

homeDir="$HOME"
trashSafermDirName=".Trash_saferm"
safeRmPath="$HOME/$trashSafermDirName"
workingDir=$(pwd)
vFlag=0
rFlag=0
dFlag=0
RFlag=0

vArg1=""
rArg1=""
dArg1=""
RArg1=""

usage(){

  echo "usage: saferm [-drv] file ..."
  		echo "	unlink file"
  		false

}

finalSafeRm(){

  userReplyYes $response
  if [[ ($? -eq 0) ]] && [[ $numberOfItemsInDirectory -eq 0 ]]
  then
    mv $currentDir $safeRmPath
    echo "$currentDir removed"
  else
    echo "$currentDir not empty"
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
  if [[ -f $* ]]; then
      read -p "remove $* ? " response
      userReplyYes $response
      if [[ ($? -eq 0) ]] ; then
          mv $1 $safeRmPath
          if [[ $vFlag -eq 1 ]]; then
            echo "$1 removed"
          fi
      else
        if [[ $vFlag -eq 1 ]]; then
          echo "$1 not removed"
        fi
      fi
  fi
}

handleEmptyDir(){

  if [[ -d $1 ]] && [[ $numberOfItemsInDirectory -eq 0 ]]; then
      read -p "remove $1 ? " response
      userReplyYes $response
      if [[ ($? -eq 0) ]] ; then
          mv $1 $safeRmPath
          echo ""
      else
          echo ""
      fi
  fi
}

recursivelyExamineDir(){

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
                     mv $currentDir/$item $safeRmPath
                else
                    echo "$currentDir/$item not removed"
                fi
        fi

            userReplyYes $response
        if [[ ($? -eq 0) ]] && [[ $numberOfContentsInDirectory -gt 0 ]]; then
                recursivelyExamineDir $currentDir/$item

                fi

        else
                read -p "remove $currentDir/$item? " response
                userReplyYes $response
                    if [[ ($? -eq 0) ]]; then
                        echo "$currentDir/$item removed"
                        mv $currentDir/$item $safeRmPath
                    else
                        echo "$currentDir/$item not removed"
                    fi
        fi

        done

    # if [[ -d $currentDir ]] ; then
        read -p "remove $currentDir? " response
        finalSafeRm $currentDir
    # else
    #     handleFile $currentDir
    # fi


    currentDir=$(dirname $currentDir)

}

handleDirNotEmpty(){

    if [[ -d "$1" ]] && [[ $numberOfItemsInDirectory -gt 0 ]]; then
            read -p "examine files in $1? " response
            userReplyYes $response
                if [[ ($? -eq 0) ]] ; then
                        recursivelyExamineDir $1
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

recoverContent(){

  item=$1
  itemPath=$workingDir/$item
  previousItemPath=$(dirname $itemPath)
  itemInTrash=$safeRmPath/$item

  read -p "recover $1? " response
  userReplyYes $response
  if [[ ($? -eq 0) ]] ; then
    mv $itemInTrash $previousItemPath
  else
    echo "$1 not recovered"
  fi
}


while getopts ":vrdR" opt ; do
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
        R)
            RFlag=1;
            RArg1=$OPTARG
            ;;
        *)
        usage
        echo "Invalid argument"
    esac
done

shift $((OPTIND-1))

if [[ $# -ne 0 ]]; then

  if [[ $RFlag -eq 1 ]]; then
    recoverContent $1
  else
    numberOfItemsInDirectory=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
  fi

  if [ ! -d "$safeRmPath" ];
  then
    mkdir "$safeRmPath"
  fi

  if [[ $rFlag -eq 1 ]]; then
    handleDirNotEmpty $1
    handleFile $*
    handleEmptyDir $1
  fi

  if [[ $vFlag -eq 1 ]] && [[ $rFlag -eq 0 ]]; then
    if [[ -f $* ]]; then
      handleFile $*
    else
      echo "SafeRm: $1: is a Directory"
      fi
  fi

  if [[ $dFlag -eq 1 ]]; then
    if [[ -f $* ]]; then
      handleFile $*
    else
      if [[ $rFlag -eq 1 ]]; then
          handleDirNotEmpty $1
      else
          if [[ $numberOfItemsInDirectory -eq 0 ]]; then
            handleEmptyDir $1
          else
            echo "safeRm: $1: Directory not empty"
          fi
      fi
    fi
  fi

  if [[ $dFlag -eq 0 ]] && [[ $rFlag -eq 0 ]] && [[ $vFlag -eq 0 ]] && [[ $RFlag -eq 0 ]]; then
    if [[ -f $* ]]; then
      handleFile $*
    fi
    if [[ -d $1 ]]; then
      echo "saferm: $1: is a directory"
    fi
  fi

else
    usage
fi
