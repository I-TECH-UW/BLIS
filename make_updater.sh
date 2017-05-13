#!/bin/bash

# This script creates a self-extracting installer shell script to update
# the /var/www/oebasic/htdocs directory to new versions of BLIS source code.
# This script was developed and tested on Ubuntu 12.04, and written to
# run on Linux systems.

DATE=`date +%Y%m%d`

echo "Creating source archive..."
tar -cjf htdocs.tar.bz2 htdocs/

echo "Creating updater..."
cat updater_script.sh htdocs.tar.bz2 >update-blis-$DATE.sh
echo "Finished creating updater: update-blis-$DATE.sh"

rm htdocs.tar.bz2

