#!/bin/bash

clear

### Define variables ###

home=$(sh -c "echo ~$(whoami)") # Great idea to safely define home by Ben Hoskings, author of "babushka" https://github.com/benhoskings/babushka

from="https://github.com/phoenixweiss/sskit/archive/master.tar.gz" # Source
to="$home/.sskit" # Destination

### Define functions ###

say() {
  printf "\n$1\n\n"
}

any() {
  type "$1" >/dev/null 2>&1
}

### Begin script ###

say "Hello, $USER"

if [ $EUID -ne 0 ]; then
  say "The script $0 must run under root privileges!"
  exit 1 # Exit with error
fi

say "Test"

exit 0 # Success exit
