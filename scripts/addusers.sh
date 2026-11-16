#!/bin/bash

names_file=$(realpath "${1:-$(dirname "$0")/../faculty_names.txt}")
cd "$(dirname "$0")/.." || exit 1

if [ "$EUID" -ne 0 ]; then
	echo "Error: this action must be run with sudo."
	exit 1
fi

if [ ! -f "$names_file" ]; then
	echo "Error: $names_file not found. Run the web scraper (menu option 1) first."
	exit 1
fi

created=0
skipped=0
failed=0

# Loops through every name in the file
while read -r first last; do
	# skip blank lines
	if [ -z "$first" ] || [ -z "$last" ]; then
		continue
	fi

	# FIXED: usernames are lowercase, letters and hyphens only (O'Brien -> obrien)
	first=${first,,}
	last=${last,,}
	first=${first//[^a-z-]/}
	last=${last//[^a-z-]/}

	# Creates a username and password
	username=$first.$last
	password=${first}${last}HALBERD

	if id "$username" &> /dev/null; then
		echo "Skipping $username (already exists)"
		skipped=$((skipped + 1))
		continue
	fi

	if sudo useradd -m -s /bin/bash "$username" && echo "$username:$password" | sudo chpasswd; then
		echo "Created $username"
		created=$((created + 1))
	else
		echo "Error: could not create $username"
		failed=$((failed + 1))
	fi
done < "$names_file"

echo "Done. Created: $created  Skipped (already existed): $skipped  Failed: $failed"