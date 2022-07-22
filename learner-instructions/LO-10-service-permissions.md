# Service Permissions

So far, when you have deployed WordPress, you have been running it from Apache httpd's default directory with default permissions. This is not ideal, as it means two things:

 - WordPress cannot modify its own files or create new ones.
 - Server admins need root access to modify WordPress files.

Today, your task has three parts.

1. Host WordPress from the ```/var/www/html/wordpress``` directory so that WordPress has the correct permissions to access its own files.
2. Harden WordPress by securing the `wp-config.php` file from being read by any other users.
3. Create a new server admin user `admin` that will share read and write permissions for most of WordPress's files... but *not* `wp-config.php`!

Happy coding!

## Notes

### User
You do not need to configure your new `admin` user for anything other than the task at hand. All you need to do is ensure the user exists, and can read and write WordPress files.

### Wordpress
Wordpress must be *safely* deployed to your machine and accessible in a web browser.

**Note:** it is *not* safe for WordPress files to be world-writable. 

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

### Apache httpd

Your only task here is to modify which directory httpd serves by default. You will not need to configure anything else in the httpd.conf file.

## Need a hint?

<details>
<summary>Small Hint</summary>
<br>
You need to configure Apache httpd to serve documents from a different directory from the default. Where do you think Apache stores this configuration?
</details>

<details>
<summary>Medium Hint</summary>
<br>
After you've deployed WordPress, you need to modify WordPress file permissions in three ways, to achieve three things. You can do this with three commands.
</details>

<details>
<summary>Large Hint</summary>
<br>

</details>