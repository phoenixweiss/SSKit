#!/bin/bash

clear

### Begin SSKit init ###

type "got_ssk" &> /dev/null
if [ $? -ne 0 ]; then
  wget -O- -q https://raw.githubusercontent.com/phoenixweiss/sskit/master/ssk_init.sh >> ~/.profile
  . ~/.profile
  export -f got_ssk # Export function for check SSKit availibility
fi

### End SSKit init ###

printf "\n"

### Begin main script ###

say "$(currtime)"

logo

sleep 2s

say "Hello, $USER! You run SSKit script under $ostype Operating System."

rootonly

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
ln -s "$home/.sskit/ssk_mkstage.sh" "/usr/local/bin/ssk_mkstage" >/dev/null 2>&1
ln -s "$home/.sskit/ssk_mkswap.sh" "/usr/local/bin/ssk_mkswap" >/dev/null 2>&1
ln -s "$home/.sskit/ssk_test.sh" "/usr/local/bin/ssk_test" >/dev/null 2>&1

printf "\n"

hr

say "Installation completed. New global commands availible:
1. $(important 'ssk_install') (this script)
2. $(important 'ssk_mkstage') (creates stage for project with nginx config and new db)
3. $(important 'ssk_mkswap') (creates proper swap-file based on RAM size)
4. $(important 'ssk_test') (test script for debug) $(warn '*')
Do not forget to use sudo for execute them!

$(warn '* currently in progress')"

hr

if [ $ostype != Linux ]; then
  say "Right at this moment further setup is possible $(warn 'ONLY') on Linux OS"
  exit 1
fi

say "Do you want to further server setup? You always be able to do it later with $(important 'sudo ssk_install')"

# TODO recomend to make swap first before install if ramsizemb < 1000

read -r -p "Continue (y/N)? " choice
case $choice in
[yY][eE][sS] | [yY] )

      ### Begin stage setup ###

      printf "\n"

      ### Begin hostname handling ###

      say "Current hostname is: $(hostname)"

      say "Please enter the new hostname (may be like this $(important server.yourdomain.com)):";

      read SERVER_NAME
      if [ ! -z "$SERVER_NAME" -a "$SERVER_NAME" != " " ];
      then
        say "Server name is set to $SERVER_NAME"
      else
        SERVER_NAME="server"
        say "Desired server name invalid. Default server name is set to $SERVER_NAME"
      fi
      sed -i "s/$(hostname)/$SERVER_NAME/g" /etc/hosts
      echo $SERVER_NAME > /etc/hostname

      say "Server name $(important $SERVER_NAME) will be used by default hostname"

      ### End hostname handling ###

      hr

      ### Begin Email reading ###

      say "Please enter email for sending notification after the success setup $(warn '(WILL CONTAIN PASSWORDS!)')"

      read SUCCESS_MAIL
      if [ ! -z "$SUCCESS_MAIL" -a "$SUCCESS_MAIL" != " " ];
      then
        say "Notofication email is set to $SUCCESS_MAIL"
      else
        SUCCESS_MAIL="root@server"
        say "Desired Notofication email invalid. Default notofication email is set to $SUCCESS_MAIL"
      fi
      say "Email $(important $SUCCESS_MAIL) will be used for success notification"

      ### End Email reading ###

      hr

      ### Begin ruby version selector ###

      say "Please enter global ruby version you wish to install:"

      read RUBY_VER

      if [ ! -z "$RUBY_VER" -a "$RUBY_VER" != " " ];
      then
        say "Desired ruby version is set to $RUBY_VER"
      else
        RUBY_VER="2.3.0"
        say "Desired ruby version invalid. Default ruby version is set to $RUBY_VER"
      fi

      ### End ruby version selector ###

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

      service mysql restart

      ### End MySQL Setup ###

      hr

      ### Begin rbenv and ruby setup ###

      say "Installing $(important 'rbenv') for user deploy"
      su - deploy -c 'curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash' # TODO make another installer myself

      echo "export RUBY_VER=$RUBY_VER" >> /home/deploy/.profile

      echo 'export RBENV_ROOT="/home/deploy/.rbenv"' >> /home/deploy/.profile

      printf '
        if [ -d "${RBENV_ROOT}" ]; then
          export PATH="${RBENV_ROOT}/bin:${PATH}"
          eval "$(rbenv init -)"
        fi
      ' >> /home/deploy/.profile

      su - deploy -c 'source /home/deploy/.profile'

      say "Install desired ruby version"
      su - deploy -c 'rbenv install --verbose $RUBY_VER'
      su - deploy -c 'rbenv global $RUBY_VER'
      su - deploy -c 'rbenv rehash'

      say "Ruby version check"
      su - deploy -c 'ruby -v'

      say "Gem update and bundler install"
      su - deploy -c 'echo "gem: --no-ri --no-rdoc" > /home/deploy/.gemrc'
      su - deploy -c 'gem update --system'
      su - deploy -c 'gem install bundler'

      ### End rbenv and ruby setup ###

      hr

      ### Begin Apache Remove ###

      say "In case of 80 port locking try to remove apache"

      netstat -tlnp | grep 80

      # TODO apache handle

      # kill 9634

      # service apache2 stop

      # apt-get purge apache2 apache2-utils apache2.2-bin apache2-common

      # apt-get autoremove

      # whereis apache2 // ---> // rm -rf /etc/apache2

      ### End Apache Remove ###

      hr

      ### Begin Passenger Setup ###

      say "Install Passenger and make all necessary configuration"

      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7

      apt-get install -y apt-transport-https ca-certificates

      echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger $(oscodename) main" > /etc/apt/sources.list.d/passenger.list

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

      ### Begin Nginx SSL Preparations ###

      say "Create folder for SSL certificates"

      mkdir /etc/nginx/ssl
      chown root:root /etc/nginx/ssl
      chmod 700 /etc/nginx/ssl
      service nginx reload

      ### End Nginx SSL Preparations ###

      hr

      ### Begin project structure ###

      say "Create folder for projects"

      su - deploy -c 'mkdir -p /home/deploy/projects/'

      say "All projects goes here: $(important '/home/deploy/projects/')"

      ### End project structure ###

      hr

      ### Begin postfix setup ###

      say "Removing standard mailer exim4"
      apt-get remove -y exim4 exim4-base exim4-config exim4-daemon-light
      apt-get purge -y exim4 exim4-base exim4-config exim4-daemon-light

      say "Install postfix"
      apt-get update --fix-missing
      echo $SERVER_NAME > "/etc/mailname"
      debconf-set-selections <<< "postfix postfix/mailname string $SERVER_NAME"
      debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
      apt-get install -y postfix

      ### End postfix setup ###

      hr

      ### Begin nodejs ###

      say "Install nodejs as native JS compile framework"

      apt-get install -y nodejs

      ### End nodejs ###

      hr

      ### Begin conclusion ###

      say "\nОтчет об установке будет отправлен на почту $SUCCESS_MAIL\n\n"

      say "Success notification sent on $(important $SUCCESS_MAIL)"

      printf "Your server $SERVER_NAME successfully installed and ready to work!

      mysql root password: $MYSQL_PASSWORD

      Public deployment key:
      $(cat /home/deploy/.ssh/id_rsa.pub)" | mail -s "Stage setup on $SERVER_NAME success" $SUCCESS_MAIL

      ### End conclusion ###

      printf "\n"

      ### End stage setup ###
      ;;

* )
      say "$(currtime)"
      exit 0 # Exit without further setup
      ;;
esac

hr

say "Bye, $USER!"

say "Please, do not forget to $(important 'reboot') server! Please do it manually!"

say "$(currtime)"

### End main script ###

# TODO reboot if not interactive!

exit 0 # Success exit
