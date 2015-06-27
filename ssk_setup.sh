#!/bin/bash

clear
. ssk_install --source-only

type "got_ssk" >/dev/null 2>&1 && echo "functions imported" || echo "functions not imported"
