#!/bin/bash

### Begin define variables ###

home=$(sh -c "echo ~$(whoami)") # Great idea to safely define home by Ben Hoskings, author of "babushka" https://github.com/benhoskings/babushka
ostype=$(uname -s) # Checks OS type
from="https://github.com/phoenixweiss/sskit/archive/master.tar.gz" # Source
to="$home/.sskit" # Destination

### End define variables ###

# TODO gather full information about release
# lsb_release -i # ID
# lsb_release -r # Version release
# lsb_release -c # Codename

### Begin define functions ###

logo() {
cat <<"LOGO"

███████╗███████╗██╗  ██╗██╗████████╗
██╔════╝██╔════╝██║ ██╔╝██║╚══██╔══╝
███████╗███████╗█████╔╝ ██║   ██║
╚════██║╚════██║██╔═██╗ ██║   ██║
███████║███████║██║  ██╗██║   ██║
╚══════╝╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝

by Paul Phönixweiß aka phoenixweiss

LOGO
}

currtime() {
  date "+%d.%m.%Y %H:%M:%S" # Shows current time in "dd.mm.YYYY HH:MM:SS" format
}

say() {
  printf "\e[1m$1\e[0m\n\n" # Pre-format script messages
}

important() {
  echo -e "\e[7m $1 \e[27m" # Show importance of some info such as passwords
}

warn() {
  echo -e "\e[31m$1\e[39m" # Text for warnings
}

hr() {
  say "- - - - - - - - - - - - - - -"
  sleep 1.5s
}

any() {
  type "$1" >/dev/null 2>&1 # Check availibility of something
}

pass_gen() {
  echo "$(date +%s | md5sum | base64 | head -c $1)" # Generates N-character-based random password
}

oscodename() {
  echo "$(lsb_release -c)" | sed 's/.*:\t//' # Extracts release codename
}

canonize() {
  echo "$1" | sed 's/[^a-zA-Z0-9]//g' # Canonization for any string
}

rootonly() {
  if [ $EUID -ne 0 ]; then
    say "The script $0 must run under $(important root) privileges!"
    say "$(currtime)"
    exit 1 # Exit with error
  fi
}

got_ssk() {
  true # Check SSKit availible in current session
}

### End define functions ###
