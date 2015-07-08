#!/bin/bash

clear

type "got_ssk" &> /dev/null
if [ $? -ne 0 ]; then
  wget -O- -q https://raw.githubusercontent.com/phoenixweiss/sskit/master/ssk_init.sh >> ~/.profile
  . ~/.profile
  export -f got_ssk # Export function for check SSKit availibility
fi

rootonly

SWAP_TEMPLATE=" "

say "You system partitions are:"

blkid

hr

say "Info about current swap(if any):"

swapon -s

hr

say "Info about free memory(include swap)"

free

hr

vmstat

hr

say "Currently, you have $(ramsizemb)Mb of RAM"

say "Do you want to make a proper swapfile based on your RAM size?"

read -r -p "Continue (y/N)? " choice
case $choice in
[yY][eE][sS] | [yY] )

      dd if=/dev/zero of=/swapfile bs=1M count=$(ramsizemb)

      chmod 600 /swapfile

      mkswap /swapfile

      swapon /swapfile

      echo "/swapfile  none  swap  defaults  0  0" >> /etc/fstab # TODO check if the line presents!

      # cat /etc/sysctl.conf | grep vm

      echo "vm.swappiness=15" >> /etc/sysctl.conf # TODO check if the line presents!

      say "$(ramsizemb)Mb swap file ready and mounted in /swapfile"

      say "Please, do not forget to $(important 'reboot') server! Please do it manually!"

      printf "\n"
      ;;
* )
      say "$(currtime)"
      exit 0 # Exit without further setup
      ;;
esac

hr

say "Bye, $USER!"

say "$(currtime)"

# TODO reboot if not interactive!

exit 0 # Success exit
