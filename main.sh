#!/bin/bash

# Define Core Variables

calFormat="dd/mm/yy"
calFileDest="/home/alpha/.toofoo/cal"
purpose=$1


printEvents(){
	IFS=$'\r\n' GLOBIGNORE='*' command eval 'calFile=($(cat $calFileDest))'
	
	for i in "${calFile[@]}"
	do
		echo "$i"
	done
}

newEvent(){
	eventDetailsCreate="$1"
	eventDateCreate="$2"

	echo "$eventDetailsCreate"   >> "$calFileDest"
	echo "$eventDateCreate"      >> "$calFileDest"
}

case $purpose in

	add) 	printf "New event:"; read eventDetails
	     	printf "Date:"; read eventDate

	     	newEvent "$eventDetails" "$eventDate"				;;
	show) 	printEvents							;;
esac
