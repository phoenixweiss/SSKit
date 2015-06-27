#!/bin/bash

clear

type "got_ssk" >/dev/null 2>&1 && echo "functions imported" || echo "functions not imported"

echo "Do you wish to install this program?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "good"; break;;
        No ) exit;;
    esac
done
