# Service Permissions

Thus far, when you have installed WordPress, you have been running it from a default Apache directory owned by the root user and root group. This is not ideal, as WordPress cannot update automatically this way.

You also need sudo access just to be able to modify WordPress files.

Today, you will fix both of these issues.

You will need to create a new directory called ```wordpress``` within ```/var/www/html```, configure httpd to be able to serve and modify documents from it, and then set up a new user with the correct permissions to manage the files within it.

Happy coding!

## Notes

### Wordpress
Wordpress must be deployed to your machine and accessible in a web browser.

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
You need to configure Apache httpd to serve documents from a different directory to the default. Where do you think Apache stores this configuration?
</details>

<details>
<summary>Medium Hint</summary>
<br>
Apache stores more than just the document root in its configuration file, but also its default user and group. How can this information help you?
</details>

<details>
<summary>Large Hint</summary>
<br>
You need to set up a new user, and ensure they are in the same group as your directory. You also need this group to have the correct permissions in this directory.
</details>