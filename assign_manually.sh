#!/usr/bin/env bash

VALID=0
TRUTH=0
ANSWER=' '

# loop until user says they don't want anymore users
while [ $TRUTH -eq 0 ]
do
	# loop until valid names are entered
	while [ $VALID -eq 0 ]
	do
		read -p "Enter your first and last name: " FIRST LAST

		# if nothing is entered
		if [[ ( -z $FIRST ) || ( -z $LAST ) ]]
		then
			echo "Not enough paramaters passed"
			continue
		# if something other than letters are entered
		elif [[ ( ! $FIRST =~ ^[A-Za-z]+$ ) || ( ! $LAST =~ ^[A-Za-z]+$ ) ]]
		then
			echo "Non alpha characters detected"
			continue
		fi
		VALID=1
	done

	# print the username and password
	echo Username: $FIRST.$LAST
	echo Password: $FIRST$LAST\HALBERD

	# making username and password for the user
	username=${FIRST}"."${LAST}
	password=${FIRST}${LAST}HALBERD
	# Creates the new user
	sudo useradd -p $password $username

	# adding another user
	read -p "Would you like to add another user? (Y/N)" ANSWER
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
