#!/bin/bash

# Take in the array of dictionaries and store it in a variable
names=$1

# Variable for iterating through the array
declare -n name_ref

# Loops through every name in the array
for name_ref in "${names[@]}"; do
	# Creates a username and password
	username=${name_ref[firstName]}"."${name_ref[lastName]}
	password=${name_ref[firstName]}${name_ref[lastName]}HALBERD
	# Creates the new user
	sudo useradd -p $password $username
done
