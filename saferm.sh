#!/bin/bash
#this is my saferm script
#this script has 3 parts: declaration of variables, declaration of functions and calling of functions and variables declared.
#-------------------------------------------------------------------------------------------------------------------------------------------------------
#declaration of variables

homeDir="$HOME"
trashSafermDirName=".Trash_saferm"
safeRmPath="$HOME/$trashSafermDirName"
workingDir=$(pwd)
vFlag=0
rFlag=0
dFlag=0
RFlag=0

#--------------------------------------------------------------------------------------------------------------------------------------------------
#declaration of functions

usage(){

  echo "usage: saferm [-drv] file ..."
  echo "	unlink file"
  		false

}

finalSafeRm(){

  userReplyYes $response
  if [[ ($? -eq 0) ]]; then
    if [[ $numberOfItemsInDirectory -eq 0 ]]; then
      mv $currentDir $safeRmPath
    else
      echo "SafeRm: $currentDir: Directory not empty"
    fi
  else
    false
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
  if [[ -f $1 ]]; then
      read -p "remove $1 ? " response
      userReplyYes $response
      if [[ ($? -eq 0) ]] ; then
          mv $1 $safeRmPath
          if [[ $vFlag -eq 1 ]]; then       #if vflag is passed
            echo "$1 "
          fi
      else
        if [[ $vFlag -eq 1 ]]; then
          false
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
      else
          false
      fi
      if [[ $vFlag -eq 1 ]] && [[ $dFlag -eq 1 ]]; then     #if vflag is combined with dflag
        echo "safeRm: $1: Directory not empty "
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
            read -p "examine files in directory $currentDir/$item? " response

            userReplyYes $response
            #examine contents in subdirectory
            if [[ ($? -eq 0) ]] && [[ $numberOfContentsInDirectory -eq 0 ]]; then
                read -p "remove $currentDir/$item? " response
                userReplyYes $response
                if [[ ($? -eq 0) ]]; then
                     mv $currentDir/$item $safeRmPath
                else
                    false
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
                        mv $currentDir/$item $safeRmPath
                    else
                        false
                    fi
        fi

        done

        read -p "remove $currentDir? " response
        finalSafeRm $currentDir


    currentDir=$(dirname $currentDir)

}

handleDirNotEmpty(){

    if [[ -d "$1" ]] && [[ $numberOfItemsInDirectory -gt 0 ]]; then
            read -p "examine files directory in $1? " response
            userReplyYes $response
                if [[ ($? -eq 0) ]] ; then
                        recursivelyExamineDir $1
                else
                    false
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

#-------------------------------------------------------------------------------------------------------------------------------------------------

#calling of variables and functions declared

while getopts ":vrdR" opt ; do
    case $opt in
        v)
            vFlag=1;
            ;;
        r)
            rFlag=1;
            ;;
        d)
            dFlag=1;
            ;;
        R)
            RFlag=1;
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


if [[ $# -ne 0 ]]; then
#check if the number of arguments passed to the script is not equal to 0, i.e an argument is passed, then the script should perform the list of actions bellow.

#for uppercase R option or flag

  if [[ $RFlag -eq 1 ]]; then                             #if an argument is passed with the upper case "R", the script should read the "recoverContent" function.
    recoverContent $1
  else
    numberOfItemsInDirectory=$(ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | wc -l | xargs)
  fi

#for lowercase r option or flag
  if [[ $rFlag -eq 1 ]]; then                              #if an argument is passed with the "rflag" then perform the 3 functions enclosed.
    handleDirNotEmpty $1
    handleFile $1
    handleEmptyDir $1
  fi

#codes below are for vflag alone, vfalg combined with dflag, vflag combined with rflag
  if [[ $vFlag -eq 1 ]] && [[ $rFlag -eq 0 ]] && [[ $dFlag -eq 0 ]]; then

                                                            #if vflag is set alone, pass action below.


    if [[ -f $1 ]]; then                                    #if its a file, then pass "handlefile" function
      handleFile $1
    else
      echo "SafeRm: $1: is a Directory"                     #else not a file, i.e a directory then echo a directory
    fi
  fi

  if [[ $dFlag -eq 1 ]]; then
    if [[ -f $1 ]]; then                                    #if "dflag" is passed and its a file, then pass "handleFile" function
      handleFile $1
    else
      if [[ $rFlag -eq 1 ]]; then                           #if "dflag" is combined with the "rflag", and passed to a dir not empty, then delete the dir.
          handleDirNotEmpty $1
      else
          if [[ $numberOfItemsInDirectory -eq 0 ]]; then
            handleEmptyDir $1
          else                                             #if "dflag" is not combined with the "rflag" and passed to a dir not empty, echo dir not empty.
            echo "safeRm: $1: Directory not empty"
          fi
      fi
    fi
  fi

  if [[ $dFlag -eq 0 ]] && [[ $rFlag -eq 0 ]] && [[ $vFlag -eq 0 ]] && [[ $RFlag -eq 0 ]]; then
    if [[ -f $1 ]]; then                                  #if  no flag is passed, then delete only a file and not a directory.
      handleFile $1
    fi
    if [[ -d $1 ]]; then
      echo "saferm: $1: is a directory"
    fi
  fi

else                                                     #if no argument is passed to the script, then tell us how to use the script.
    usage
fi
