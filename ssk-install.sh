#!/bin/bash

clear

### Define functions ###

say() {
  printf "\n$1\n\n"
}

any() {
  type "$1" >/dev/null 2>&1
}

### Begin script ###

say "Hello, $USER"

if [ $EUID -ne 0 ]; then
  say "The script $0 must run under root privileges!"
  exit 1 # Exit with error
fi

say "Test"

exit 0 # Success exit
