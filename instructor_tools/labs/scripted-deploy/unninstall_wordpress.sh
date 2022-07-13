# remove packages
yum remove php-mysqlnd php-fpm mysql-server httpd php-json

#remove wordpress folder
rm -rf "/var/www/html/wordpress/"
