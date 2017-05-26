#!/bin/bash

# This is the header for a self-extracting archive script to update
# BLIS sources to the newest version. It is used by make_updater.sh to 
# create a single-file installer for BLIS updates.

# check for root, re-invoke as root if not
[[ $(id -u) -eq 0 ]] || exec sudo /bin/bash -c "$(printf '%q ' "$BASH_SOURCE" "$@")"

ROOT='/var/www/oebasic'

if [ ! -d "$ROOT/htdocs" ]; then
  echo "BLIS installation not found in $ROOT/htdocs"
  exit 0
fi

DATE=`date +%Y%m%d`
LONGDATE=`date +%Y%m%d-%H%M%S`
PAYLOAD_LINE=`awk '/^__PAYLOAD_BELOW__/ {print NR + 1; exit 0; }' \$BASH_SOURCE`

GET_BLIS_DBS_QUERY="select schema_name from information_schema.schemata"
GET_BLIS_DBS_QUERY+=" where schema_name like 'blis%'"

dbs=`mysql -u root -B --skip-column-names -e "$GET_BLIS_DBS_QUERY"`
backupdir=$ROOT/update_backups
thisbackup=$backupdir/$LONGDATE

echo "Shutting down the webserver..."
service apache2 stop

echo "Updating webserver configuration..."
sed -i 's_DocumentRoot /var/www$_DocumentRoot /var/www/oebasic/htdocs_' /etc/apache2/sites-available/default
sed -i 's_Directory /var/www/>_Directory /var/www/oebasic/htdocs/>_' /etc/apache2/sites-available/default
sed -i 's_DocumentRoot /var/www$_DocumentRoot /var/www/oebasic/htdocs_' /etc/apache2/sites-available/default-ssl
sed -i 's_Directory /var/www/>_Directory /var/www/oebasic/htdocs/>_' /etc/apache2/sites-available/default-ssl

echo "Backing up databases..."
mkdir -p $thisbackup/databases-$DATE

# backup databases
for dbname in $dbs
do
  backupfile="$thisbackup"
  backupfile+="/databases-$DATE/"
  backupfile+="$dbname"
  backupfile+="_$LONGDATE.sql"
  echo "Backing up $dbname..."
  mysqldump -u root --add-drop-database --create-options --databases \
  $dbname | sed -e 's/\/\*!50017 DEFINER=`.*`@`.*`\*\///' > $backupfile
done

echo "Backing up source code..."
mv $ROOT/htdocs $thisbackup/htdocs-$DATE
chown -R root.root $thisbackup

echo "Extracting new source code..."
tail -n+$PAYLOAD_LINE $BASH_SOURCE | tar -xj -C $ROOT

# set owner and permissions for webserver
chown -R www-data.www-data $ROOT/htdocs
chmod -R 755 $ROOT/htdocs

echo "Restarting webserver..."
service apache2 start

echo "Finishing up..."
# compress the sql dumps and source code, remove uncompressed copies
tar -C $thisbackup -cjf $backupdir/blis-backup-$LONGDATE.tar.bz2 ./
rm -rf $thisbackup

echo "Upgrade complete!"
echo "Backup copy: $backupdir/blis-backup-$LONGDATE.tar.bz2"
echo
echo
echo "Log in to BLIS to complete database upgrades."
echo
echo
exit 0

__PAYLOAD_BELOW__
