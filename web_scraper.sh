#!/bin/bash

#Run from inside the project folder:  sudo ./main.sh
URL="https://www.tntech.edu/engineering/programs/csc/faculty-and-staff.php"

# Web Scraper
scrape_names() {
    echo "Downloading faculty page..."
    if ! curl -s -f -o faculty_page.html "$URL"; then
        echo "Error: could not download the page."
        return
    fi
    # HTML was recongized to contain this for each user (Kedrick G)
    # <h4><strong>Gerald Gannod, Ph.D.</strong></h4>

    tr '\n' ' ' < faculty_page.html \
        | grep -oP '<h4.?</h4>' \
        | sed 's/<[^>]>//g' \
        | sed 's/&nbsp;/ /g' \
        | sed 's/,.*//' \
        | while read -r -a words; do
              if [ ${#words[@]} -ge 2 ]; then
                  echo "${words[0]} ${words[-1]}"
              fi
          done > faculty_names.txt

    echo "Found $(wc -l < faculty_names.txt) names. Saved to faculty_names.txt"
}