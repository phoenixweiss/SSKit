#!/bin/bash

clear

type "got_ssk" &> /dev/null
if [ $? -ne 0 ]; then
  wget -O- -q https://raw.githubusercontent.com/phoenixweiss/sskit/master/ssk_init.sh >> ~/.profile
  . ~/.profile
  export -f got_ssk # Export function for check SSKit availibility
fi

rootonly

EXPECTED_ARGS=2 # Number of expected arguments
E_BADARGS=65 # Bad arguments error code
MYSQL="$(which mysql)"
proj_sql_pass="$(pass_gen 12)"
canonic_name="$(canonize $1 | head -c 16)"
conftype=$2

if [ $# -ne $EXPECTED_ARGS ]
then
  say "How to use script: $0 latin_domain_name config_type"
  say "Config types may be: php, html, rails, sinatra"
  say "You will need to enter MySQL root password, so $(warn 'prepare it!')"
  exit $E_BADARGS
fi

case $conftype in
      php | html | rails | sinatra )

      cp $home/.sskit/templates/$conftype.conf /etc/nginx/conf.d/$1.conf

      sed -i "s|%%domain%%|$1|g" /etc/nginx/conf.d/$1.conf
      sed -i "s|%%canonic_name%%|$canonic_name|g" /etc/nginx/conf.d/$1.conf

      su - deploy -c "mkdir -p /home/deploy/projects/$1/shared/config/"

      Q1="CREATE DATABASE IF NOT EXISTS $canonic_name CHARACTER SET utf8;"
      Q2="GRANT ALL ON $canonic_name.* TO '$canonic_name'@'localhost' IDENTIFIED BY '$proj_sql_pass';"
      Q3="FLUSH PRIVILEGES;"
      Q4="SELECT User,Host FROM mysql.user;"
      Q5="SHOW DATABASES;"
      SQL="${Q1}${Q2}${Q3}${Q4}${Q5}"

      # config for database.yml
      DB_CONFIG="
      production:
        adapter: mysql2
        encoding: utf8
        host: localhost
        reconnect: true
        database: $canonic_name
        pool: 5
        username: $canonic_name
        password: $proj_sql_pass
        # socket: /tmp/mysql.sock
      "
      say "Please enter MySQL root password:"

      $MYSQL -uroot -p -e "$SQL" # DO NOT FORGET MYSQL ROOT PASSWORD

      printf "$DB_CONFIG" > /home/deploy/projects/$1/shared/config/database.yml

      chmod -R 755 /home/deploy/projects/$1/shared/config/*
      chown -R deploy /home/deploy/projects/$1/shared/config/*
      chgrp -R deploy /home/deploy/projects/$1/shared/config/*

      openssl req -new -x509 -days 9999 -nodes -newkey rsa:2048 -subj /C=RU/O=$canonic_name/CN=$1/emailAddress=info@$1 -out /etc/nginx/ssl/$canonic_name.pem -keyout /etc/nginx/ssl/$canonic_name.key

      say "Stage for $1 is ready"
      say "Project working directory: /home/deploy/projects/$1"
      say "DB config file: /home/deploy/projects/$1/shared/config/database.yml"
      say "Self-signed certs are here: /etc/nginx/ssl/"
      say "Proper Nginx config file: /etc/nginx/conf.d/$1.conf"

      service nginx restart

      exit 0

      ;;
* )
      say "No such conftype"
      exit 0 # Exit without further setup
      ;;
esac
