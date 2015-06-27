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

got_ssk() {
  true # Check SSKit availible in current session
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
    elif any 'apt-get'; then # on production Debian
      say "Installing curl via apt-get"
      apt-get install curl
    else
      say "Please install curl manually then start the script again!"
      say "$(currtime)"
      exit 1 # Exit with error
    fi
fi

# Check if install directory exists
if [ -d "$to" ]; then
  say "Old version of SSKit found, handle it."
  rm -rf "$to" # Remove it recursively
  cd "$home"
fi

mkdir -p "$to" && cd "$to"
say "Installing SSKit into $(pwd)"
curl -L -\# "$from" | tar -zxf - --strip-components 1
chmod +x *.sh

ln -s "$home/.sskit/ssk_install.sh" "/usr/local/bin/ssk_install"
ln -s "$home/.sskit/ssk_setup.sh" "/usr/local/bin/ssk_setup"

set -a

# TODO export -f got_ssk # Export function to verify SSKit installation test

say "Installation completed. New global commands availible:\n$(important 'ssk_install')\n$(important 'ssk_setup')"

say "$(currtime)"

exit 0 # Success exit
