#!/bin/bash

clear

type "got_ssk" &> /dev/null
if [ $? -ne 0 ]; then
  wget -O- -q https://raw.githubusercontent.com/phoenixweiss/sskit/master/ssk_init.sh >> ~/.profile
  . ~/.profile
  export -f got_ssk # Export function for check SSKit availibility
fi

rootonly

EXPECTED_ARGS=1 # Number of expected arguments
E_BADARGS=65 # Bad arguments error code
MYSQL="$(which mysql)"
proj_sql_pass="$(pass_gen 12)"
canonic_name="$(canonize $1)"

if [ $# -ne $EXPECTED_ARGS ]
then
  say "How to use script: $0 latin_domain_name"
  exit $E_BADARGS
fi

NGINX_CONFIG="server {
\t listen 80;
\t server_name www.$1 $1;
\t root /home/deploy/projects/$1/current/public;
\t passenger_enabled on;
\t rails_env production;
\t location ~ ^/assets/ {
\t\t expires 1y;
\t\t add_header Cache-Control public;
\t\t add_header ETag \"\";
\t\t break;
\t }
}
"

printf "$NGINX_CONFIG" > /etc/nginx/conf.d/$1.conf

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

$MYSQL -uroot -p -e "$SQL" # DO NOT FORGET MYSQL ROOT PASSWORD

printf "$DB_CONFIG" > /home/deploy/projects/$1/shared/config/database.yml

say "To make sure project work use:"
say $(important "tail -f /home/deploy/projects/$1/shared/log/production.log")

service nginx restart

exit 0
