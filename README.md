syncdb
======

syncdb is a shell script that takes a mysqldump of a remote database, zips it up, copies it to your localhost, unzips it and loads it into a local database. If you run Magento, it'll also update the `core_config_data` table to your local URL.

Usage
-----

Set the proper permissions on this file, update the config variables and run:

```
./syncdb.sh
```

Example of output when running script:

```
$ ./syncdb.sh 
host
Creating zipped backup of remote database
Transferring backup from remote to local
host
database.tmp.sql.tar.gz                               100%  128KB 128.0KB/s   00:01    
host
Unzipping mysql backup
Reloading local database (may take few moments)
Updating config
Complete!
```

This script assumes that you have SSH Keys setup for connecting to your remote host. If you do not, you'll need to modify the script as necessary.

NOTE: If you are not running a Magento store, you don't need to define `LOCAL_BASE_URL` and can remove lines 11, 30, & 31.

Options
-------

- `REMOTE_HOST`: The SSH info for your remote host. Ex: `user@host`
- `REMOTE_MYSQL_HOST`: MySQL server hostname for your remote host.
- `REMOTE_MYSQL_DB`: MySQL database name for your remote host.
- `REMOTE_MYSQL_USER`: MySQL username for your remote host.
- `REMOTE_MYSQL_PASS`: MySQL password for your remote host.
- `LOCAL_MYSQL_HOST`: MySQL server hostname for your local host.
- `LOCAL_MYSQL_DB`: MySQL database name for your local host.
- `LOCAL_MYSQL_USER`: MySQL username for your local host.
- `LOCAL_MYSQL_PASS`: MySQL password for your local host.
- `LOCAL_BASE_URL`: Local URL for your Magento instance (ensure trailing slash). Ex. `http://domain.local/`

