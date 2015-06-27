#!/bin/bash

clear

### Define variables ###

home=$(sh -c "echo ~$(whoami)") # Great idea to safely define home by Ben Hoskings, author of "babushka" https://github.com/benhoskings/babushka

from="https://github.com/phoenixweiss/sskit/archive/master.tar.gz" # Source
to="$home/.sskit" # Destination

### Define functions ###

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
  printf "\n\e[1m$1\e[0m\n\n" # Pre-format script messages
}

important() {
  echo -e "\e[7m$1\e[27m" # Show importance of some info such as passwords
}

any() {
  type "$1" >/dev/null 2>&1 # Check availibility of something
}

### Begin script ###

say "$(currtime)"

logo

say "Hello, $USER"

if [ $EUID -ne 0 ]; then
  say "The script $0 must run under root privileges!"
  say "$(currtime)"
  exit 1 # Exit with error
fi

if any 'curl'; then
  say "You have already got curl, no need to install it."
else
  say "SSKit needs curl for further work."
    if any 'brew'; then # for test on Mac
      say "Installing curl via brew"
      brew install curl
    elif any 'apt-get'; then # on production
      say "Installing curl via apt-get"
      apt-get install curl
    else
      say "Please install curl manually then start the script again!"
      exit 1 # Exit with error
    fi
fi

# Check if install directory exists
if [ -d "$to" ]; then
  say "Old version of SSKit found, handle it."
  rm -rf "$home/.sskit" # Remove it cause incompatibility
  cd "$home"
fi

mkdir -p "$to" && cd "$to"
say "Installing into $(pwd)"
curl -L -\# "$from" | tar -zxf - --strip-components 1
ls -la

# say "Some important info:\n$(important TEST)"
# TODO . ./script.sh --source-only

say "$(currtime)"

exit 0 # Success exit
