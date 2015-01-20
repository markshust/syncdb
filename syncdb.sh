#!/bin/bash
#
# author: mark shust <mark@shust.com>
#

# Update these config variables with your values
REMOTE_HOST="user@host"
REMOTE_MYSQL_HOST="localhost"
REMOTE_MYSQL_DB="database"
REMOTE_MYSQL_USER="username"
REMOTE_MYSQL_PASS="password"
LOCAL_MYSQL_HOST="localhost"
LOCAL_MYSQL_DB="database"
LOCAL_MYSQL_USER="username"
LOCAL_MYSQL_PASS="password"
LOCAL_BASE_URL="http://domain.local/"

# Make sure no backups are currently being ran
if [[ `ssh $REMOTE_HOST 'test -e ~/'$REMOTE_MYSQL_DB'.tmp.sql && echo exists'` == *exists* ]]; then
  echo "Backup is currently being executed by another process. Please try again in a few moments."
  exit 1  
fi

echo "Creating zipped backup of remote database"
ssh $REMOTE_HOST 'mysqldump -h '$REMOTE_MYSQL_HOST' -u '$REMOTE_MYSQL_USER' -p'$REMOTE_MYSQL_PASS' '$REMOTE_MYSQL_DB' > ~/'$REMOTE_MYSQL_DB'.tmp.sql' &> /dev/null
ssh $REMOTE_HOST 'tar -czf '$REMOTE_MYSQL_DB'.tmp.sql.tar.gz '$REMOTE_MYSQL_DB'.tmp.sql' &> /dev/null

echo "Transferring backup from remote to local"
scp $REMOTE_HOST:~/$REMOTE_MYSQL_DB.tmp.sql.tar.gz ~/
ssh $REMOTE_HOST 'rm ~/'$REMOTE_MYSQL_DB'.tmp*'

echo "Unzipping mysql backup" 
tar -xzf ~/$REMOTE_MYSQL_DB.tmp.sql.tar.gz -C ~/
echo "Reloading local database (may take few moments)"
mysql --verbose -u $LOCAL_MYSQL_USER -h $LOCAL_MYSQL_HOST -p$LOCAL_MYSQL_PASS $LOCAL_MYSQL_DB < ~/$REMOTE_MYSQL_DB.tmp.sql &> /dev/null
echo "Updating config"
mysql -u $LOCAL_MYSQL_USER -h $LOCAL_MYSQL_HOST -p$LOCAL_MYSQL_PASS $LOCAL_MYSQL_DB -e "UPDATE core_config_data SET value='$LOCAL_BASE_URL' WHERE path='web/unsecure/base_url' OR path='web/secure/base_url';"

# Clean local temp files
rm ~/$REMOTE_MYSQL_DB.tmp*

echo "Complete!"

