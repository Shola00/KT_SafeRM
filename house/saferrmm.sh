#!/bin/bash
#test short code in scripts

for i in $( ls -l "$1" | sort -k1,1 | awk -F " " '{print $NF}' | sed -e '$ d' | xargs ); do

	read -p "type what you want:" xxx
	echo "i typed $xxx on file $i"
done
