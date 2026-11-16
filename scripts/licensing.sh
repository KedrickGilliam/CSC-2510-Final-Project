#!/usr/bin/env bash

# The hash of the real 16-digit key (the key itself is never written anywhere).
# readonly means these two values can't be changed while the program runs.
readonly LICENSE_SHA256="062cc03ae273dc3800d5786e464e14d2c4a4886e362dc7c57c9d56d1b21cfc45"

# Where the license file is saved: in the home folder of whoever runs the program.
# ${XDG_STATE_HOME:-$HOME/.local/state} means "use XDG_STATE_HOME if it is set,
# otherwise use ~/.local/state". With sudo, this is root's home folder.
readonly LICENSE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/halberd/onboarding-license.dat"

# hash_key KEY - prints the SHA-256 hash of KEY
#   printf sends the key to sha256sum, which prints "<hash>  -";
#   awk keeps only the first word (the hash).
hash_key() { printf '%s' "$1" | sha256sum | awk '{print $1}'; }

check_license() {
    local stored key old_umask

    # 1. Already licensed? If the license file exists and holds the right hash,
    #    the program is licensed, so return 0 right away (no key needed).
    if [[ -f "$LICENSE_FILE" ]]; then
        stored=$(<"$LICENSE_FILE")
        if [[ "$stored" == "$LICENSE_SHA256" ]]; then return 0; fi
        # The file exists but was edited or damaged, so ask for the key again
        printf 'Stored license invalid. Re-activation required.\n' >&2
    fi

    # 2. The key must be typed by a person. -t 0 is true when the input comes from
    #    a terminal; if the key is being piped in from a file or another program,
    #    stop instead of reading it.
    if [[ ! -t 0 ]]; then
        printf 'No valid license; run interactively to activate.\n' >&2
        return 1
    fi

    # 3. Ask for the key. -s hides what is typed; -r reads it exactly as typed.
    read -r -s -p 'Enter your 16-digit license key: ' key
    printf '\n'

    # 4. The key must be exactly 16 digits AND its hash must match LICENSE_SHA256.
    #    ^[0-9]{16}$ means: start, exactly 16 digits, end.
    if [[ ! "$key" =~ ^[0-9]{16}$ ]] || [[ "$(hash_key "$key")" != "$LICENSE_SHA256" ]]; then
        printf 'Invalid license key.\n' >&2
        return 1
    fi

    # 5. Save the license file so the key isn't asked for again.
    #    umask 077 makes the new folder and file private (only this user can read
    #    them). The old umask is saved first and put back afterward, so files the
    #    program creates later (like faculty_names.txt) get normal permissions.
    old_umask=$(umask)
    umask 077
    mkdir -p -- "$(dirname -- "$LICENSE_FILE")" || { umask "$old_umask"; return 1; }
    printf '%s\n' "$LICENSE_SHA256" > "$LICENSE_FILE" || { umask "$old_umask"; return 1; }
    umask "$old_umask"
    chmod 600 "$LICENSE_FILE"    # owner can read and write; nobody else can

    # Forget the typed key now that it has been checked
    unset key
    printf 'License activated.\n'
}