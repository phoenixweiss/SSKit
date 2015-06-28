#!/bin/bash

clear

### Define variables ###

home=$(sh -c "echo ~$(whoami)") # Great idea to safely define home by Ben Hoskings, author of "babushka" https://github.com/benhoskings/babushka
from="https://github.com/phoenixweiss/sskit/archive/master.tar.gz" # Source
to="$home/.sskit" # Destination
ostype=$(uname -s) # Checks OS type

# TODO gather full information about release
# lsb_release -i # ID
# lsb_release -r # Version release
# lsb_release -c # Codename

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

osrelcodename() {
  echo "$(lsb_release -c)" | sed 's/.*:\t//' # Extracts release codename
}

got_ssk() {
  true # Check SSKit availible in current session
}

export -f got_ssk # Export function for check SSKit availibility

### Begin script ###

say "$(currtime)"

logo

sleep 2s

say "Hello, $USER! You run SSKit script under $ostype Operating System."

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
      printf "\n"
    elif any 'apt-get'; then # on production Debian
      say "Installing $(important curl) via apt-get"
      apt-get -y install curl
      printf "\n"
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

hr

mkdir -p "$to" && cd "$to"
say "Installing SSKit into $(pwd)"
curl -L -\# "$from" | tar -zxf - --strip-components 1
chmod +x *.sh

ln -s "$home/.sskit/ssk_install.sh" "/usr/local/bin/ssk_install" >/dev/null 2>&1
ln -s "$home/.sskit/ssk_test.sh" "/usr/local/bin/ssk_test" >/dev/null 2>&1

printf "\n"

hr

say "Installation completed. New global commands availible:
1. $(important 'ssk_install') (this script)
2. $(important 'ssk_mkstage') (creates stage for project with nginx config and new db) $(warn '*')
3. $(important 'ssk_dbcreate') (creates only new db) $(warn '*')
4. $(important 'ssk_test') (test script for debug)
Do not forget to use sudo for execute them!

$(warn '* in progress')"

hr

if [ $ostype != Linux ]; then
  say "Right at this moment further setup is possible $(warn 'ONLY') on Linux OS"
  exit 1
fi

say "Do you want to further server setup? You always be able to do it later with $(important 'sudo ssk_install')"

select yn in "Yes" "No"; do
    case $yn in
        Yes )

          ### Begin stage setup ###

          printf "\n"

          ### Begin Email reading ###

          say "Please enter email for sending notification after the success setup $(warn '(WILL CONTAIN PASSWORDS!)')"

          read SUCCESS_MAIL # TODO make sure email not empty

          say "Email $(important $SUCCESS_MAIL) will be used for success notification"

          ### End Email reading ###

          hr

          ### Begin hostname handling ###

          say "Current hostname is: $(hostname)"

          say "Please enter the new hostname (may be like this $(important server.yourdomain.com)):";

          read SERVER_NAME # TODO make sure server name not empty
          sed -i "s/$(hostname)/$SERVER_NAME/g" /etc/hosts
          echo $SERVER_NAME > /etc/hostname

          say "Server name $(important $SERVER_NAME) will be used by default hostname"

          ### End hostname handling ###

          hr

          ### Begin locale generate ###

          # TODO add more locales support

          say "We need to add other locale support. Right now only $(important 'ru_RU') is supported by SSKit"

          if grep -q -x "ru_RU.UTF-8 UTF-8" "/etc/locale.gen"; then
            say "Locale ru_RU found, generate"
            locale-gen
          else
            say "Locale ru_RU not found, add and generate"
            echo "ru_RU.UTF-8 UTF-8" >> "/etc/locale.gen"
            locale-gen
          fi

          printf "\n"

          ### End locale generate ###

          hr

          ### Begin update ###

          say "Update all"
          apt-get update
          apt-get -y upgrade
          apt-get -y autoremove
          apt-get -y install ssh

          ### End update ###

          hr

          ### Begin prepare deploy user ###

          say "Install sudo"

          apt-get -y install sudo # TODO check if sudo exists

          say "Checking $(important 'deploy') user"

          id -u deploy &> /dev/null

          if [ $? -ne 0 ]
          then
            say "There is no user $(important 'deploy'), create new with same name group and make him sudoer"
            groupadd -f deploy
            useradd -m -g deploy -s /bin/bash deploy
            chmod +w /etc/sudoers
            echo "deploy ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
            chmod -w /etc/sudoers
          else
            say "User $(important 'deploy') already exists"
          fi

          say "Checking for .ssh directory"
          if [ ! -d /home/deploy/.ssh ]
          then
            say "There is no $(important '.ssh') directory, create new with proper rights"
            mkdir /home/deploy/.ssh
            chmod 700 /home/deploy/.ssh
            chown deploy /home/deploy/.ssh
            chgrp deploy /home/deploy/.ssh
          fi

          say "Generating deployment keys"
          ssh-keygen -b 2048 -t rsa -C "deploy@$SERVER_NAME" -f /home/deploy/.ssh/id_rsa -q -N ""
          chmod -R 600 /home/deploy/.ssh/*
          chown -R deploy /home/deploy/.ssh/*
          chgrp -R deploy /home/deploy/.ssh/*

          say "There is your public deployment key:"
          hr
          important "$(cat /home/deploy/.ssh/id_rsa.pub)"
          printf "\n"
          hr

          if [ -d /root/.ssh ]
          then

            if [ -f /root/.ssh/authorized_keys ]
            then
            say "Duplicate existing root authorized_keys to deploy user with proper rights"
            cp /root/.ssh/authorized_keys /home/deploy/.ssh/
            chmod 600 /home/deploy/.ssh/authorized_keys
            chown deploy /home/deploy/.ssh/authorized_keys
            chgrp deploy /home/deploy/.ssh/authorized_keys
            fi

          fi

          say "Make passwordless sudo for deploy"
          sed -i "s/.*PasswordAuthentication yes.*/PasswordAuthentication no/g" "/etc/ssh/sshd_config"
          service ssh restart

          ### End prepare deploy user ###

          hr

          # TODO separate nginx install like this
          #
          # if grep -q "deb http://ftp.ru.debian.org/debian/ wheezy-backports main contrib non-free" "/etc/apt/sources.list"; then
          #   apt-get update
          # else
          #   echo "deb http://ftp.ru.debian.org/debian/ wheezy-backports main contrib non-free" >> "/etc/apt/sources.list"
          #   apt-get update
          # fi
          #
          # apt-get -t wheezy-backports install -y nginx

          ### Begin packages install ###

          say "Install all necessary packages"

          apt-get install -y debconf lsb-core git git-core gcc make imagemagick libmagickwand-dev libcurl4-openssl-dev autoconf bison build-essential libssl-dev libyaml-dev libxml2-dev libxslt1-dev libreadline-dev zlib1g zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev

          printf "\n"

          ### End packages install ###

          hr

          ### Begin MySQL Setup ###

          say "Setup MySQL with random generated password"
          MYSQL_PASSWORD="$(pass_gen 16)"
          say "Your MySQL password is $(important $MYSQL_PASSWORD)"
          debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
          debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
          apt-get -y install mysql-server mysql-client libmysqlclient-dev

          say "Make $(important 'max_allowed_packet') 64M"
          sed -i "s|.*max_allowed_packet.*|max_allowed_packet = 64M|" /etc/mysql/my.cnf

          # TODO ln -s /run/mysqld/mysqld.sock /tmp/mysql.sock

          service mysql restart

          ### End MySQL Setup ###

          hr

          ### Begin rbenv and ruby setup ###

          say "Installing $(important 'rbenv') for user deploy"
          su - deploy -c 'curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash' # TODO make another installer mysqlf

          echo 'export RBENV_ROOT="/home/deploy/.rbenv"' >> /home/deploy/.profile

          printf '
            if [ -d "${RBENV_ROOT}" ]; then
              export PATH="${RBENV_ROOT}/bin:${PATH}"
              eval "$(rbenv init -)"
            fi
          ' >> /home/deploy/.profile

          su - deploy -c 'source /home/deploy/.profile'

          say "Install the latest ruby version" # TODO make version input or selector
          su - deploy -c 'rbenv install 2.2.2'
          su - deploy -c 'rbenv global 2.2.2'
          su - deploy -c 'rbenv rehash'

          say "Ruby version check"
          su - deploy -c 'ruby -v'

          say "Gem update and bundler install"
          su - deploy -c 'echo "gem: --no-ri --no-rdoc" > /home/deploy/.gemrc'
          su - deploy -c 'gem update --system'
          su - deploy -c 'gem install bundler'

          ### End rbenv and ruby setup ###

          hr

          ### Begin Passenger Setup ###

          say "Install Passenger and make all necessary configuration"

          apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7

          apt-get install -y apt-transport-https ca-certificates

          echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger $(osrelcodename) main" > /etc/apt/sources.list.d/passenger.list

          chown root /etc/apt/sources.list.d/passenger.list
          chmod 600 /etc/apt/sources.list.d/passenger.list
          apt-get update

          apt-get install -y --force-yes nginx-full nginx-extras passenger

          apt-get update --fix-missing
          apt-get -y autoremove

          sed -i "s|www-data;|deploy;|g" "/etc/nginx/nginx.conf"
          sed -i "s|# passenger_root.*|passenger_root $(/usr/bin/passenger-config --root);|" /etc/nginx/nginx.conf
          sed -i "s|# passenger_ruby.*|passenger_ruby /home/deploy/.rbenv/shims/ruby;|" /etc/nginx/nginx.conf
          sed -i "s|# server_tokens off.*|client_max_body_size 20M;|" /etc/nginx/nginx.conf

          service nginx restart

          ### End Passenger Setup ###

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
