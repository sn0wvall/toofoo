#!/bin/bash

# Define Core Variables

calFormat="dd/mm/yy"
calFileDest="/home/alpha/.toofoo/cal"
purpose=$1
IFS=$'\r\n' GLOBIGNORE='*' command eval 'calFile=($(cat $calFileDest))'
x=0
y=1

# Define Core Functions

printEvents(){

	case $1 in
		today)	echo "Showing events today"		;;
		*)	echo "Showing all Events"; echo
			for i in "${calFile[@]}"
			do
				echo "$i"
			done					;;
	esac

}

newEvent(){

	eventDetailsCreate="$1"
	eventDateCreate="$2"

	echo "$eventDetailsCreate"   >> "$calFileDest"				# In future, ordering the events in the file by date may be a useful feature.
	echo "$eventDateCreate"      >> "$calFileDest"
}

deleteEvent(){

	target="$1"
	while [ $x -lt ${#calFile[@]} ]
	do
		test "${calFile[$x]}" = "$target" && sed -i "$y"d $calFileDest && sed -i "$y"d $calFileDest && printf "\nDeleted Event ${calFile[$x]}" && return 0
		((x=x+2))			# Optimally, I would have used some inbuilt (()) style maths to calculate line number, however sed wouldn't work with it
		((y=y+2))			# Therefore, I opted for a more ham-fisted solution of using two variables.
	done
	echo "Event Name not Found"

}

case $purpose in

	add) 	printf "New event:"; read eventDetails
	     	printf "Date:"; read eventDate

	     	newEvent "$eventDetails" "$eventDate"						;;
	
	show) 	printEvents $2									;;

	del)	printf "Event Name to Delete: "; read deleteTarget
			deleteEvent "$deleteTarget"						;;
	*)		echo "\"$1\" is not a known command"					;;
esac
