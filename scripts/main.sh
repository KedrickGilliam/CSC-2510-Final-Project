#!/bin/bash
# Run from the eagle-ops folder:  sudo ./scripts/main.sh

cd "$(dirname "$0")/.." || exit 1

source scripts/licensing.sh
if ! check_license; then
    exit 1
fi

while true; do
    echo
    echo "===== hAlberd Faculty Onboarding ====="
    echo "1) Scrape faculty names (default)"
    echo "2) Create users from the list"
    echo "3) Add a single user"
    echo "4) Exit"
    read -r -p "Choose an option [1]: " choice || exit 0   # Ctrl-D exits

    # Pressing Enter with no number runs the default (option 1)
    if [ -z "$choice" ]; then
        choice=1
    fi

    case $choice in
        1) scripts/web_scraper.sh ;;
        2) scripts/addusers.sh faculty_names.txt ;;
        3) scripts/assign_manually.sh ;;
        4) echo "Goodbye."; exit 0 ;;
        *) echo "Invalid option. Enter 1-4." ;;
    esac
done