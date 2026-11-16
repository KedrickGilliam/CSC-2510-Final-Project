<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/EagleOps_logo_dark.png">
    <img src="assets/EagleOps_logo.png" alt="Eagle-Ops logo" width="260">
  </picture>
</p>

# hAlberd Technologies Faculty Onboarding Tool

Built by **Eagle-Ops**

## Overview

The Faculty Onboarding Tool is a Bash program that creates Ubuntu accounts for every faculty and staff member listed on the Tennessee Tech Computer Science [Faculty and Staff page](https://www.tntech.edu/engineering/programs/csc/faculty-and-staff.php). It downloads the page, extracts each person's first and last name, and creates an account for each one using the hAlberd naming standard.

The program is made up of five scripts that run from one menu:

| File | Project part | What it does |
| --- | --- | --- |
| `main.sh` | Menu | Shows the menu and runs the script for each part |
| `web_scraper.sh` | Part 1 | Downloads the faculty page and saves each first and last name to `faculty_names.txt` (default menu action) |
| `addusers.sh` | Part 2 | Creates an Ubuntu account for every name in the parsed list |
| `assign_manually.sh` | Part 3 | Creates accounts from first and last names typed in by the operator, one after another |
| `licensing.sh` | Part 4 | Checks for a valid license before the menu opens; asks for the key if there is none (written with AI assistance) |

All five scripts are in the `scripts/` folder.

The program also creates these files in the `eagle-ops/` folder as it runs. None of them are uploaded to GitHub (`.gitignore` keeps them out):

| File | Created by | What it holds |
| --- | --- | --- |
| `~/.local/state/halberd/onboarding-license.dat` | Part 4, after a valid key is entered | The license, so the key isn't asked for again. It is saved in the home folder of the user who runs the program (with `sudo`, that is root's home folder), not in `eagle-ops/` |
| `faculty_names.txt` | Part 1 | The scraped first and last names, one per line |
| `faculty_page.html` | Part 1 | The downloaded faculty page |

Press **Enter** to scrape the faculty names, then choose option **2** to create the accounts.

## Requirements

The tool is built for Ubuntu 26.04 with Bash 5.3, running on an x86 VMware virtual machine.

- **Administrative access:** creating accounts requires `sudo`.
- **curl:** used to download the faculty page. Install it with `sudo apt install curl` if `curl --version` fails.
- **Internet access:** the VM must be able to reach `www.tntech.edu`.
  -  If you need to check internet access, you can run `ping www.tntech.edu` or `ping 192.168.1.1.1` in the terminal. You need **0%** packet loss and all packets need to be reached.
- **Standard tools:** `grep`, `sed`, `useradd` and `chpasswd` ship with Ubuntu; nothing else needs installing.
  - Run `sudo apt update && sudo apt upgrade` if you haven't recently.

## Installation

Copy the project folder onto the Ubuntu VM and make the scripts executable.

1. Clone the team repository (or unzip `halberd_onboarding.zip`):

   ```bash
   git clone https://github.com/KedrickGilliam/CSC-2510-Final-Project.git eagle-ops
   cd eagle-ops
   ```

2. Make the scripts executable:

   ```bash
   chmod +x scripts/*.sh
   ```

All the scripts must stay together in the `scripts/` folder. The program can be started from any folder; it always works from `eagle-ops/` and saves its files there. The folder looks like this:

```
eagle-ops/
├── README.md               # instructions & documentation [YOU ARE HERE]
├── .gitignore              # restricts hidden files from being pushed
├── faculty_names.txt       # scraped names (created by option 1)
├── faculty_page.html       # downloaded faculty page (created by option 1)
├── assets/
│   ├── EagleOps_logo.png        # team logo (light backgrounds)
│   └── EagleOps_logo_dark.png   # team logo (dark backgrounds)
└── scripts/
    ├── main.sh             # menu & main script
    ├── web_scraper.sh      # web scraper                             (Part 1)
    ├── addusers.sh         # bulk account creation                   (Part 2)
    ├── assign_manually.sh  # manual add user                         (Part 3)
    └── licensing.sh        # license check                           (Part 4)
```

## Running The Program

Start the program from the project folder with `sudo`, then pick an option from the menu.

```bash
sudo ./scripts/main.sh
```

```
----- hAlberd Faculty Onboarding -----
1) Scrape faculty names (default)
2) Create users from the list
3) Add a single user
4) Exit
Choose an option [1]:
```

The menu returns after each action, so options can be run one after another. Pressing **Enter** without typing a number runs option 1.

### Before the menu: license check (Part 4)

Every time the program starts, it checks for a valid license before showing the menu.

- **First run:** no license file exists yet, so the program asks for the 16-digit license key:

  ```
  Enter your 16-digit license key:
  License activated.
  ```

  The key is hidden as it is typed, and it must be typed in a terminal (it can't be piped in from a file or another program). A valid key saves the license file, `~/.local/state/halberd/onboarding-license.dat`, so the key is not asked for again.

- **Later runs:** the program finds the license file, confirms it is valid, and goes straight to the menu.

- **Invalid key:** the program prints an error and exits without showing the menu:

  ```
  Enter your 16-digit license key:
  Invalid license key.
  ```

The license key is provided by email to the stakeholders (the instructor and TA) by the team's scrum master. It is never stored in plain text: the program only stores its SHA-256 hash.

### Option 1: Scrape faculty names (default)

This option downloads the faculty page and saves every person's first and last name to `faculty_names.txt`, one per line, in the order they appear on the page. Credentials such as "Ph.D." are removed, and middle names or initials are dropped.

```
Downloading faculty page...
Found 38 names. Saved to faculty_names.txt
```

To see the list, run `cat faculty_names.txt`. The scraper can also be run on its own, without the menu: `./scripts/web_scraper.sh`.

Run this option before option 2. Running it again overwrites the list with the page's current contents.

### Option 2: Create Ubuntu users from the parsed list

This option creates one Ubuntu account for every name in `faculty_names.txt`. Each account gets a home directory in `/home` and a Bash shell. Accounts that already exist are skipped, so the option is safe to run more than once.

```
Created gerald.gannod
Created maanak.gupta
...
Done. Created: 38  Skipped (already existed): 0  Failed: 0
```

### Option 3: Add a single user manually

This option creates an account for a person who is not on the website. Type the first and last name on one line when prompted; the same naming rules as option 2 apply. After each account, answer **Y** to add another user or **N** to go back to the menu.

```
Enter your first and last name: Jane Doe
Username: jane.doe
Password: janedoeHALBERD
Created jane.doe
Would you like to add another user? (Y/N)N
Thank you. GOODBYE!
```

Names may contain letters, apostrophes and hyphens. A blank name shows `Not enough parameters passed`, and a name with numbers or other symbols shows `Non alpha characters detected`; either way, the name is asked for again.

The script can also be run on its own without the menu: `sudo ./scripts/assign_manually.sh`.

### Option 4: Exit

Closes the program. Pressing **Ctrl-D** at the menu also exits.

## Licensing

The license protects hAlberd's software from unauthorized use. The program will not run without a valid 16-digit license key. The licensing code, `scripts/licensing.sh`, was written with AI assistance, as Part 4 of the project requires.

| Item | Details |
| --- | --- |
| How the key is delivered | Emailed to the instructor and TA by the scrum master (not automated). The team keeps the key in `STAKEHOLDER_KEY_DO_NOT_COMMIT.txt`, outside the repository and the submission ZIP |
| How the key is protected | Only the key's SHA-256 hash is stored, in the `LICENSE_SHA256` line of `scripts/licensing.sh`; the key itself never appears in the code |
| Where the license is saved | `~/.local/state/halberd/onboarding-license.dat`, in the home folder of the user who runs the program, readable only by that user (permissions 600) |
| Who is licensed | Each operating-system user activates separately. Because the program is run with `sudo`, the license is saved for root |
| Reset the license | Delete the license file; the program asks for the key again on the next run |

**Changing the key (scrum master):**

1. Pick a new 16-digit key and print its hash (replace the digits with the new key):

   ```bash
   printf '%s' "1234567812345678" | sha256sum
   ```

2. Paste the long code it prints into the `LICENSE_SHA256="..."` line in `scripts/licensing.sh`.
3. Delete the license file and email the new key to the instructor and TA.

**Keeping the key safe on GitHub:**

- `STAKEHOLDER_KEY_DO_NOT_COMMIT.txt` and any key files are listed in `.gitignore`, so they are never pushed to the repository.
- The license file is saved in the user's home folder, outside the project, so it is never pushed either.

## Naming rules

Every account follows the hAlberd standard: the username is `first.last` and the temporary password is `firstnamelastnameHALBERD`. Names are converted to lowercase, and any character that is not a letter or hyphen is removed.

| Name on page | Username | Temporary password |
| --- | --- | --- |
| Gerald Gannod, Ph.D. | `gerald.gannod` | `geraldgannodHALBERD` |
| Doug Talbert, Ph.D. | `doug.talbert` | `dougtalbertHALBERD` |
| Sonya Haney | `sonya.haney` | `sonyahaneyHALBERD` |
| Jane O'Brien (added manually) | `jane.obrien` | `janeobrienHALBERD` |

The name part of the password is lowercase because the project specification writes it that way. If the team decides on capitalized names instead, change the `password=` line in both `scripts/addusers.sh` and `scripts/assign_manually.sh` so Parts 2 and 3 stay the same.

## Verifying results

After option 1, check the parsed list; after option 2, confirm the accounts exist.

**Check the scraper output.** The page lists 38 faculty and staff members, and each line should be just a first and last name:

```bash
wc -l faculty_names.txt          # should print 38 faculty_names.txt
cat faculty_names.txt            # first and last names, one per line, in page order
```

**Check an account:**

```bash
id gerald.gannod                 # shows the account exists
su - gerald.gannod               # log in; password: geraldgannodHALBERD
```

**Remove the test accounts** (for example, to reset the VM before a live demo):

```bash
while read -r f l; do sudo userdel -r "${f,,}.${l,,}"; done < faculty_names.txt
```

## Troubleshooting

| Message or problem | Cause | Fix |
| --- | --- | --- |
| `Error: this action must be run with sudo.` | Options 2 and 3 need administrator rights | Start the program with `sudo ./scripts/main.sh` |
| `Error: could not download the page.` | The VM has no internet access, or the site is down | Check with `ping www.tntech.edu` |
| `Found 0 names.` | The website's layout changed, so names are no longer in `<h4>` headings | Open `faculty_page.html`, find the tag around a name, and update the `grep` line in `scripts/web_scraper.sh` |
| `faculty_names.txt not found` | Option 2 was run before option 1 | Run option 1 first |
| Extra lines such as "Quick Links" in the list | Another part of the page also uses `<h4>` headings | Delete the extra lines from `faculty_names.txt`, or narrow the `grep` pattern |
| `Permission denied` when starting | The scripts are not executable | Run `chmod +x scripts/*.sh` |
| `Skipping first.last (already exists)` | The account was created on an earlier run | No action needed |
| `Invalid license key.` | The key was mistyped, is not 16 digits, or is not the issued key | Run the program again and re-enter the 16-digit key from the email |
| `No valid license; run interactively to activate.` | The key was piped in, or the program was started without a terminal | Run `sudo ./scripts/main.sh` in a terminal and type the key |
| `Stored license invalid. Re-activation required.` | The license file was edited or damaged, or the key was changed | Type the 16-digit key again when asked |
| The program asks for the key again after it was activated | It was activated as a different user (for example, without `sudo`); each user has their own license | Run it the same way every time: `sudo ./scripts/main.sh` |

## Security notes

- **The key is hashed, not encrypted.** SHA-256 is a one-way hash: it hides the key from anyone reading the code, but someone who can edit the scripts could remove the license check. Local licensing like this discourages unauthorized use; it can't fully prevent it.
- **The license file stores the hash, not the key.** It could be copied to another account. Stronger licensing would need a license server or a digitally signed, machine-bound license.
- **The required password pattern is predictable.** `firstnamelastnameHALBERD` follows the project specification but is not a production security practice. In production, use random temporary passwords delivered securely, password expiration, and a forced password change at first login.
- **The scraper depends on the website's layout.** If Tennessee Tech changes its faculty page, check the scraper's results (`cat faculty_names.txt`) before creating accounts.

## AI usage

- **Part 4, `scripts/licensing.sh`:** Written with AI assistance, as the instructions require. This covers the SHA-256 key check, key validation, saving the license file, and loading it from `main.sh`.

The team reviewed and tested all of the code and is responsible for it.

## Sources

- [Tennessee Tech CS Faculty and Staff page](https://www.tntech.edu/engineering/programs/csc/faculty-and-staff.php)