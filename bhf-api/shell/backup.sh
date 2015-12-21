#!/bin/sh

# Database info
DB_NAME="bhf"
DB_USER="root"
DB_PASS="123456"
BIN_DIR="/usr/bin"

BCK_DIR="/var/backup/bhf-api/mysql"
DATE=`date +%F`

$BIN_DIR/mysqldump --opt -u$DB_USER -p$DB_PASS $DB_NAME | gzip >$BCK_DIR/db_$DATE.gz
echo "Backup sucessful -> $BCK_DIR/db_$DATE.gz"