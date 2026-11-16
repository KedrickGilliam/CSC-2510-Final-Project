#!/usr/bin/env bash
#Part 3

if [ "$EUID" -ne 0 ]; then
	echo "Error: this action must be run with sudo."
	exit 1
fi

VALID=0
TRUTH=0
ANSWER=' '

# loop until user says they don't want anymore users
while [ $TRUTH -eq 0 ]
do
	# loop until valid names are entered
	while [ $VALID -eq 0 ]
	do
		# FIXED: stop if the input ends (for example, Ctrl-D); before, this looped forever
		if ! read -r -p "Enter your first and last name: " FIRST LAST
		then
			echo
			exit 1
		fi

		# if nothing is entered
		if [[ ( -z $FIRST ) || ( -z $LAST ) ]]
		then
			echo "Not enough parameters passed"
			continue
		# if something other than letters are entered
		elif [[ ( ! $FIRST =~ ^[A-Za-z\'-]+$ ) || ( ! $LAST =~ ^[A-Za-z\'-]+$ ) ]]
		then
			echo "Non alpha characters detected"
			continue
		fi
		VALID=1
	done

	# making username and password for the user
	FIRST=${FIRST,,}
	LAST=${LAST,,}
	FIRST=${FIRST//\'/}
	LAST=${LAST//\'/}
	username=${FIRST}"."${LAST}
	password=${FIRST}${LAST}HALBERD

	# print the username and password
	echo "Username: $username"
	echo "Password: $password"

	if id "$username" &> /dev/null
	then
		echo "Skipping $username (already exists)"
	# Creates the new user

	elif sudo useradd -m -s /bin/bash "$username" && echo "$username:$password" | sudo chpasswd
	then
		echo "Created $username"
	else
		echo "Error: could not create $username"
	fi

	# adding another user
	read -r -p "Would you like to add another user? (Y/N)" ANSWER
	if [[ $ANSWER == 'Y' ]] || [[ $ANSWER == 'y' ]]
	then
		TRUTH=0
		VALID=0
		echo "Alright, let us add another user"
	# not adding another user and exits program
	elif [[ $ANSWER == 'N' ]] || [[ $ANSWER == 'n' ]]
	then
		TRUTH=1
		echo "Thank you. GOODBYE!"
	# anything other than Y or N immediately exits the program
	else
		TRUTH=1
		echo "I'll assume you want to exit"
	fi
done
