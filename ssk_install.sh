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
  printf "\e[1m$1\e[0m\n\n" # Pre-format script messages
}

important() {
  echo -e "\e[7m$1\e[27m" # Show importance of some info such as passwords
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

got_ssk() {
  true # Check SSKit availible in current session
}

export -f got_ssk # Export function for check SSKit availibility

### Begin script ###

say "$(currtime)"

logo

sleep 2s

say "Hello, $USER! You run SSKit script under $(uname -s) Operating System."

if [ $EUID -ne 0 ]; then
  say "The script $0 must run under $(important root) privileges!"
  say "$(currtime)"
  exit 1 # Exit with error
fi

if any 'curl'; then
  say "You have already got $(important curl), no need to install it."
else
  say "SSKit needs $(important curl) for further work."
    if any 'brew'; then # for test on Mac
      say "Installing $(important curl) via brew"
      brew install curl
    elif any 'apt-get'; then # on production Debian
      say "Installing $(important curl) via apt-get"
      apt-get install curl
    else
      say "Please install $(important curl) manually then start the script again!"
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

ln -s "$home/.sskit/ssk_install.sh" "/usr/local/bin/ssk_install" >/dev/null 2>&1
ln -s "$home/.sskit/ssk_test.sh" "/usr/local/bin/ssk_test" >/dev/null 2>&1

hr

say "Installation completed. New global commands availible:
1. $(important 'ssk_install') (this script)
2. $(important 'ssk_mkstage') (creates stage for project with nginx config and new db) $(warn '*')
3. $(important 'ssk_dbcreate') (creates only new db) $(warn '*')
4. $(important 'ssk_test') (test script for debug)
Do not forget to use sudo for execute them!

$(warn '* in progress')"

hr

say "Do you want to further server setup? You always be able to do it later with $(important 'sudo ssk_install')"

select yn in "Yes" "No"; do
    case $yn in
        Yes )

          ### Begin stage setup ###

          printf "\n"

          say "Please enter email for sending notification after the success setup $(warn '(WILL CONTAIN PASSWORDS!)')"

          read SUCCESS_MAIL

          say "Email $(important $SUCCESS_MAIL) will be used for success notification"

          hr

          say "Please enter the server name (may be like this $(important server.yourdomain.com)):";

          read SERVER_NAME

          say "Server name $(important $SERVER_NAME) will be used by default"

          ### End stage setup ###

          break
          ;;
        No )
          say "$(currtime)"
          exit 0 # Exit without further setup
          ;;
    esac
done

hr

say "Bye, $USER!"

say "$(currtime)"

exit 0 # Success exit
