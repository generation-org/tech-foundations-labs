# Restrict Service Network Acess

In this lab you're going to restrict the network access in the instance.

Restrict the network to allow only your IP and the IP address given by your instructor, and the ports 80 and 22.

You must also set up a working wordpress deployment.

Both Wordpress and the firewall configuration must persist after reboot. 

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
