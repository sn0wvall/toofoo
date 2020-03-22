#!/bin/bash

# Define Core Variables

calFormat="dd/mm/yy"
calFileDest="/home/alpha/.toofoo/cal"
purpose=$1
IFS=$'\r\n' GLOBIGNORE='*' command eval 'calFile=($(cat $calFileDest))'
x=0

# Define Core Functions

printEvents(){
	
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

deleteEvent(){

	target="$1"
	while [ $x -lt ${#calFile[@]} ]
	do
		test "${calFile[$x]}" = "$target" && sed "/$x/d" $calFileDest &>/dev/null && return 0
		((x=x+1))
	done
	echo "Event Name not Found"

}

case $purpose in

	add) 	printf "New event:"; read eventDetails
	     	printf "Date:"; read eventDate

	     	newEvent "$eventDetails" "$eventDate"				;;
	
	show) 	printEvents							;;

	del)	printf "Event Name to Delete: "; read deleteTarget
		deleteEvent "$deleteTarget"					;;
esac
