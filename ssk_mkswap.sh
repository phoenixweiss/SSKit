#!/bin/bash

clear

type "got_ssk" &> /dev/null
if [ $? -ne 0 ]; then
  wget -O- -q https://raw.githubusercontent.com/phoenixweiss/sskit/master/ssk_init.sh >> ~/.profile
  . ~/.profile
  export -f got_ssk # Export function for check SSKit availibility
fi

rootonly

# Get swap details
SWAPUSED=`free -m | grep 'Swap:' | awk '{ print $3 }'`
SWAPTOTAL=`free -m | grep 'Swap:' | awk '{ print $2 }'`

say "You system partitions are:"

blkid

hr

say "Info about current swap(if any):"

cat /proc/swaps

hr

say "Info about free memory(with swap):"

free

hr

vmstat

hr

say "Currently, you have $(ramsizemb) Mb of real RAM, $SWAPTOTAL Mb of swap ($SWAPUSED Mb used right now)"

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

      say "$(ramsizemb) Mb swap file ready and mounted in /swapfile"

      say "To check all info about using memory try $(important 'cat /proc/meminfo')"

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
