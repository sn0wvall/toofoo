#!/bin/bash

#TODO:
# Recurring events


# Define Core Variables

x=0
y=1
z=0
w=0
date=$(date +%d/%m/%y)
found=false
confFileLocations=("$XDG_CONFIG_HOME/toofoo/config" "$HOME/.toofoo/config" "$HOME/.toofoorc" "$HOME/.config/toofoo/config")

# Define Core Functions

confFileGenerate(){										# Test to see if a configuration file is present; otherwise, generate one

	while [ $z -lt ${#confFileLocations[@]} ]; do
		test -e "${confFileLocations[$z]}" && confFile="${confFileLocations[$z]}"
		((z=z+1))
	done
	test "$confFile" && return 0
	printf "Creating new config file in $HOME/.config/toofoo/. If you don't want to use a different path, leave this field blank: "; read -r confFileLocationNew

	test -z "$confFileLocationNew" && confFileLocationNew="$XDG_CONFIG_HOME/toofoo/"
	test -d "$confFileLocationNew" || mkdir -p "$confFileLocationNew"

	echo "Desired Calendar File Absolute Path (e.g. /home/user/.toofoo/cal): "; read -r calFileDest
	echo "Desired Date Format (Please use standard date(1) units, e.g. %d): "; read -r calFormat
	echo "calFileDest=$calFileDest" >> "$confFileLocationNew/config"
	echo "calFormat=$calFormat"	>> "$confFileLocationNew/config"

	confFile="$confFileLocationNew"

	echo "Configuration Complete. Run script again to apply config."

	exit 0
}

printHelp(){											# Output the help information to the user

    cat <<-EOF
		usage: toofoo [show|new|del]
		
		show|print
			- Parameters: [today|tomorrow|yesterday|date]
			- Shows events on the specified day
			e.g. toofoo show date 12/12/20

		new|add
			- Parameters: n/a
			- Queries user for new event and date
			- Date formats are those listed in date(1): e.g. 5 March 2019, 5/7/19
		
		del|rm
			- parameters: n/a
			- Queries user for event to delete

	EOF

}

findEvents(){											# Sort and output events using a target date

	IFS=$'\r\n' GLOBIGNORE='*' command eval "calFile=($(cat $calFileDest))"

	case $1 in
		today)	target=$(date +%d/%m/%y)						
			target2=$(date +%m/%d/%y)
			;;
		*)	target=$(date -d "$1" +%d/%m/%y)
	esac
	while [ $x -lt ${#calFile[@]} ]
	do
		test "${calFile[$x]}" = "$target" && echo "${calFile[$y]}" && found=true 
		((x=x+1))
		((y=x-1))
	done
	
	x=0
	y=0

	# Redundant checks for when dates are in a different format

	while [ $x -lt ${#calFile[@]} ]
	do
		((number=$y-$w))
		test "${calFile[$x]}" = "$target2" && echo "${calFile[$y]}" && found=true 
		((x=x+1))
		((y=x-1))
	done

	test $found = false && echo "No Events" || return 0

}

printEvents(){											# Output events to the user

	IFS=$'\r\n' GLOBIGNORE='*' command eval "calFile=($(cat "$calFileDest"))"
	test "$1" = "date" && test -z $2 && echo "Error: \"date\" parameter requires a date" && return 1

	case $1 in
		today)	printf "SHOWING EVENTS TODAY, $date\n\n"; findEvents today		;;
		date)	printf "SHOWING EVENTS ON $2\n\n"; findEvents $2 			;;
		*)	echo "SHOWING ALL EVENTS"; echo 

			while [ $x -lt ${#calFile[@]} ]; do
				((number=$y-$w))
				echo "$number ${calFile[$x]}, on ${calFile[$y]}" && found=true && ((w=w+1))
				((x=x+2))
				((y=y+2))
			done								
			test $found = true || echo "No Events"
	esac
}

dateCreate(){											# Converts dates into a standardized format

	targetDate="$1"

	grep -q -e '-' -e '/' -e '\.'<<<$targetDate || return 1

	targetDate1=$(echo "$targetDate" | grep -e '-' -e '/' -e '.' | cut -d'/' -f1)
	targetDate2=$(echo "$targetDate" | grep -e '-' -e '/' -e '.' | cut -d'/' -f2)

	test $targetDate1 -gt 12 && test $targetDate2 -lt 13 && return 2			# Exit Code 2 Represents "use raw date"
	test $targetDate1 -lt 13 && test $targetDate2 -gt 12 && return 1 			# Exit Code 1 Represents "use standard date(1) conversion
	test $targetDate1 -gt 12 && test $targetDate2 -gt 12 && return 3			# All other non-zero exit codes are invalid dates
	test $targetDate1 -gt 31 && test $targetDate2 -gt 12 && return 3			# All other non-zero exit codes are invalid dates
	test $targetDate1 -gt 12 && test $targetDate2 -gt 31 && return 3			# All other non-zero exit codes are invalid dates


	return 1
}

mathable(){

	targetDate="$1"

	grep -q -e '-' -e '/' -e '\.'<<<$targetDate || return 1

	targetDate1=$(echo "$targetDate" | grep -e '-' -e '/' -e '.' | cut -d'/' -f1)
	targetDate2=$(echo "$targetDate" | grep -e '-' -e '/' -e '.' | cut -d'/' -f2)
	targetDate3=$(echo "$targetDate" | grep -e '-' -e '/' -e '.' | cut -d'/' -f3)

	test $targetDate1 -gt 12 && test $targetDate2 -lt 13 && convertOrder=1
	test $targetDate1 -lt 13 && test $targetDate2 -gt 12 && convertOrder=2
	test $targetDate1 -lt 12 && test $targetDate2 -lt 12 && convertOrder=2



	case $convertOrder in
		
		1)	mathDate="$targetDate2/$targetDate1/$targetDate3"			;;
		2)	mathDate="$targetDate"										;;

	esac

	echo $mathDate

}

newEvent(){											# Generate new events and write them to the calendar file

	IFS=$'\r\n' GLOBIGNORE='*' command eval "calFile=($(cat $calFileDest))"

	eventDetailsCreate="$1"
	eventDateCreateRaw="$2"
	dateCreate "$eventDateCreateRaw"

	case $? in
		1) eventDateCreate="$(date -d "$targetDate" "+$calFormat")"			;;
		2) eventDateCreate=$eventDateCreateRaw						;;
		*) exit 1									;;
	esac

	case $3 in
		yes|y)
			printf "Input repeat period (daily): "; read -r period
			printf "Iterations: "; read -r iterations
			case $period in
				daily)	
					iterationsDone=0
					eventDateCreateRaw="$2"
					mathDate=$(mathable $eventDateCreateRaw)

					while [ $iterationsDone -lt $iterations ]; do

						newDate=$(date -d "$mathDate +$iterationsDone day")
						newEvent "$eventDetailsCreate" "$newDate"
						((iterationsDone=iterationsDone+1))
						
					done
					exit 0
				;;
				weekly)
					iterationsDone=0
					eventDateCreateRaw="$2"
					mathDate=$(mathable $eventDateCreateRaw)
					while [ $iterationsDone -lt $iterations ]; do

						newDate=$(date -d "$mathDate +$iterationsDone week")
						newEvent "$eventDetailsCreate" "$newDate"
						((iterationsDone=iterationsDone+1))
						
					done
					exit 0					
				;;
				yearly)								
				
				;;
			esac	
	esac
	
	echo "\"$eventDetailsCreate\"" 		>> "$calFileDest"
	echo "$eventDateCreate" 		>> "$calFileDest"

}

deleteEvent(){											# Remove events from the calendar file using sed

	IFS=$'\r\n' GLOBIGNORE='*' command eval "calFile=($(cat $calFileDest))"

	target="$1"
	test "$target" = "*" && echo > "$calFileDest" && echo "Deleted all events" && return 0
	while [ $x -lt ${#calFile[@]} ]
	do
		((number=$y-$w))
		test "$number" = "$target" && sed -i "$y"d $calFileDest && sed -i "$y"d $calFileDest && echo "Deleted Event ${calFile[$x]}" && return 0
		((x=x+2))
		((y=y+2))
		((w=w+1))
	done
	echo "Event Name not Found"

}

confFileGenerate

source "$confFile"										# After configuration file path is generated by confFileGenerate, source it for use in the script

case $1 in

	add|new) 	printf "New event:"; read eventDetails
	     		printf "Date:"; read eventDate
			printf "Recurring:"; read eventType

	     		newEvent "$eventDetails" "$eventDate" "$eventType"				;;
	
	show|print) 	printEvents $2 $3								;;

	del|rm)		test -n "$2" && deleteTarget="$2" && deleteEvent "$deleteTarget" && exit 
			printf "Event Number to Delete: "; read deleteTarget
			deleteEvent "$deleteTarget"							;;

	help|h)		printHelp									;;

	*)		printEvents today								;;
esac
