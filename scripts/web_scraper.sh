#!/bin/bash
#Part 1

URL="https://www.tntech.edu/engineering/programs/csc/faculty-and-staff.php"

saved_page=""
if [ -n "$1" ]; then
    saved_page="$(realpath "$1")"
fi
cd "$(dirname "$0")/.." || exit 1

if [ -n "$saved_page" ]; then
    echo "Using saved page: $saved_page"
    if ! cp "$saved_page" faculty_page.html; then
        echo "Error: could not read $saved_page"
        exit 1
    fi
else
    echo "Downloading faculty page..."
    if ! curl -s -f -o faculty_page.html "$URL"; then
        echo "Error: could not download the page."
        exit 1
    fi
fi

# HTML was recognized to contain this for each user (Kedrick G):
#   <h4><strong>Gerald Gannod, Ph.D.</strong></h4>

tr '\n' ' ' < faculty_page.html \
    | grep -oP '<h4.*?</h4>' \
    | sed 's/<[^>]*>//g' \
    | sed 's/&nbsp;/ /g' \
    | sed 's/,.*//' \
    | while read -r -a words; do
          if [ ${#words[@]} -ge 2 ]; then
              echo "${words[0]} ${words[-1]}"
          fi
      done > faculty_names.txt

echo "Found $(wc -l < faculty_names.txt) names. Saved to faculty_names.txt"
