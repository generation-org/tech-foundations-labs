# Scheduled backups

An unfortunate accident has led to your WordPress deployment to be completely deleted. If only you had kept timely backups.

**Today, this is exactly what you will set up.**

You have been provided with the command that will be used for restoring from a backup.

```
cd /var/www/html; sudo tar xpf /backups/wordpress.tar.*
```

Your tasks today are as follows:
 - Create a solution that works with these instructions.
 - Automate the process to create a backup every Friday at 23:59.
 - Synchronise a local copy of the `wordpress/` directory inside `/backups/`.
     - **Note: This process should only sync files that have been altered.**
 - Automate this process to occur every Monday at 03:00 in the morning.

Happy coding!

## Notes

### Schedules

Not all Linux systems run systemd. Therefore, do not assume that the WordPress directory will always be restored to a machine that runs systemd.

### Permissions

Ensure that `apache` has user and group ownership of WordPress's files. You do not need to set up a new user, or grant group permissions. Permissions for `wp-config.php` should be set to `400`. Directories and files should be set to the default `755` and `644` respectively.

### SELinux

We have disabled SELinux; we will be learning about this in a future lab but for now it has been turned off.

### MySQL

We have deployed MySQL server for you, as well as created a database ready for you to use. The username is `wordpress`, the database name is `wordpress`, and the password is the same as your user password. You can see it by running `systemctl status mysqld`:

```
$ systemctl status mysqld
● mysqld.service - MySQL 8.0 database server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2027-11-21 01:47:02 UTC; 15min ago
  Process: 1105 ExecStartPost=/usr/libexec/mysql-check-upgrade (code=exited, status=0/SUCCESS)
  Process: 852 ExecStartPre=/usr/libexec/mysql-prepare-db-dir mysqld.service (code=exited, status=0/SUCCESS)
  Process: 812 ExecStartPre=/usr/libexec/mysql-check-socket (code=exited, status=0/SUCCESS)
 Main PID: 889 (mysqld)
   Status: "Server is operational"
    Tasks: 37 (limit: 4680)
   Memory: 380.1M
   CGroup: /system.slice/mysqld.service
           └─889 /usr/libexec/mysqld --basedir=/usr
```

**Note:** if you break the mysqld service then you will have made your Lab infinitely harder! It should be sufficient to leave it alone and enter the username/password/db name when prompted.

## Need a hint?

<details>
<summary>Small Hint</summary>
<br>
You need to archive and compress WordPress data in an expected location. This directory may need to be created.
</details>

<details>
<summary>Medium Hint</summary>
<br>
Linux commands will do different things depending on the directory you run them from. This is called the command's working directory.
</details>

<details>
<summary>Large Hint</summary>
<br>
You are being asked to create a compressed archive for the wordpress/ directory, and you are separately being asked to synchronise that directory to another directory.
</details>