# Deploy WordPress

WordPress is a very popular Content Management System, used by over 40% of the top 10 million websites. It is a classic LAMP stack application - that is, it runs on Linux, Apache httpd, MySQL and PHP.

**Today you will be deploying it.**

Once you've completed this task, you will be able to enter the hostname of your server in your browser and it will load an unpopulated WordPress website.

## Notes

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
You want to install WordPress on CentOS 8. WordPress wants a LAMP stack. CentOS 8 Linux is already installed, and a MySQL server is already running. What else do you need to have a full LAMP stack installed and running?
</details>

<details>
<summary>Medium Hint</summary>
<br>
After you've installed a full LAMP stack, you need to get the four components to be able to talk to each other. Apache httpd needs to be able to access PHP, and PHP needs to be able to interact with MySQL.
</details>

<details>
<summary>Large Hint</summary>
<br>
If you try to serve WordPress using Apache httpd without the correct PHP modules installed, you will see a critical error message in your web browser window. You may be able to find a list of packages that install these missing PHP modules that applies to CentOS 8.
</details>
