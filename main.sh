#!/bin/bash

# Define Core Variables

calFormat="+%d/%m/%y"
calFileDest="/home/alpha/.toofoo/cal"
purpose=$1
IFS=$'\r\n' GLOBIGNORE='*' command eval 'calFile=($(cat $calFileDest))'
x=0
y=1
date=$(date +%d/%m/%y)
found=false

# Define Core Functions

printHelp(){	

    cat <<-EOF
		usage: toofoo [show|new|del]
		
		show
			- Parameters: [today|tomorrow|yesterday|date]
			- Shows events on the specified day
			e.g. toofoo show date 12/12/20

		new
			- Parameters: n/a
			- Queries user for new event and date
			- Date formats are those listed in date(1): e.g. 5 March 2019, 5/7/19
		
		del
			- parameters: n/a
			- Queries user for event to delete
	EOF

}

findEvents(){
	case $1 in
		today)	target=$(date +%d/%m/%y)						;;
		*)	target=$(date -d "$1" +%d/%m/%y)
	esac
	while [ $x -lt ${#calFile[@]} ]
	do
		test "${calFile[$x]}" = "$target" && echo "${calFile[$y]}" && found=true 
		((x=x+1))
		((y=x-1))
	done
	test $found = false && echo "No Events" || return 0

}

printEvents(){
	
	test "$1" = "date" && test -z $2 && echo "Error: \"date\" parameter requires a date" && return 1

	case $1 in
		today)	printf "SHOWING EVENTS TODAY, $date\n\n"; findEvents today		;;
		date)	printf "SHOWING EVENTS ON $2\n\n"; findEvents $2 			;;
		*)	echo "SHOWING ALL EVENTS"; echo
			while [ $x -lt ${#calFile[@]}  ]
			do
				echo "${calFile[$x]}, on the ${calFile[$y]}"
				((x=x+2))
				((y=y+2))
			done									;;
	esac

}

newEvent(){

	eventDetailsCreate="$1"
	eventDateCreateRaw="$2"
	eventDateCreate=$(date -d "$eventDateCreateRaw" "$calFormat" 2>/dev/null) || return 1 
	[ $? -eq 1 ] 
	echo "$eventDetailsCreate"	>> "$calFileDest"				 #In future, ordering the events in the file by date may be a useful feature.
	echo "$eventDateCreate"      	>> "$calFileDest"
}

deleteEvent(){

	target="$1"
	while [ $x -lt ${#calFile[@]} ]
	do
		test "${calFile[$x]}" = "$target" && sed -i "$y"d $calFileDest && sed -i "$y"d $calFileDest && echo "Deleted Event ${calFile[$x]}" && return 0
		((x=x+2))			# Optimally, I would have used some inbuilt (()) style maths to calculate line number, however sed wouldn't work with it
		((y=y+2))			# Therefore, I opted for a more ham-fisted solution of using two variables.
	done
	echo "Event Name not Found"

}

case $purpose in

	add) 	printf "New event:"; read eventDetails
	     	printf "Date:"; read eventDate

	     	newEvent "$eventDetails" "$eventDate"						;;
	
	show) 	printEvents $2 $3									;;

	del)	printf "Event Name to Delete: "; read deleteTarget
			deleteEvent "$deleteTarget"						;;

	help)	printHelp									;;

	*)	echo "\"$1\" is not a known command"						;;
esac
