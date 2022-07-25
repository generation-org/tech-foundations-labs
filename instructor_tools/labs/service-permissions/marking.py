# tests for whether wordpress has been deployed
## is there a wp-login.php file?
def test_wp_login_is_file(host):
    wp_login = host.file("/var/www/html/wordpress/wp-login.php")
    assert wp_login.is_file

# tests for whether DocumentRoot is set to /var/www/html/wordpress
def test_httpd_conf_directory(host):
    content = File("/etc/httpd/conf/httpd.conf").content
    assert b'DocumentRoot "/var/www/html/wordpress' in content

# tests for whether wordpress owns its own files and directories
## are files user-owned by apache ?
def test_files_owned_by_apache(host):
    wp_apache_user_flag = True
    wordpress_dir = '/var/www/html/wordpress/'

    for each_file in host.file(wordpress_dir).listdir():
        current_location = wordpress_dir + each_file

        if host.file(current_location).user == 'apache':
            continue
        else:
            wp_apache_user_flag = False
            break

    assert wp_apache_user_flag

# tests for whether a new admin user can read and write files in /var/www/html/wordpress
## does the admin user exist ?
def test_admin_user_exists(host):
    assert host.user("admin").exists
## is the new user in the same group as the files in /var/www/html/wordpress ?
def test_admin_user_shares_group(host):
    wp_admin_group_flag = True
    wordpress_dir = '/var/www/html/wordpress/'

    user_group_list = host.user("admin").groups

    for each_file in host.file(wordpress_dir).listdir():
        current_location = wordpress_dir + each_file

        if host.file(current_location).group in user_group_list:
            continue
        else:
            wp_admin_group_flag = False
            break
    
    assert wp_admin_group_flag
## are file permissions set to 664 ?
def test_file_permissions(host):
    wp_file_permissions_flag = True
    wordpress_dir = '/var/www/html/wordpress/'

    for each_file in host.file(wordpress_dir).listdir():
        current_location = wordpress_dir + each_file
        if current_location == "wp_config.php":
            continue

        if host.file(current_location).is_file == True:
            if host.file(current_location).mode == 0o664:
                continue
            else:
                if host.file(current_location)
                wp_file_permissions_flag = False
    
    assert wp_file_permissions_flag
## are directory permissions set to 775 ?
def test_directory_permissions(host):
    wp_directory_permissions_flag = True
    wordpress_dir = '/var/www/html/wordpress/'

    for each_file in host.file(wordpress_dir).listdir():
        current_location = wordpress_dir + each_file

        if host.file(current_location).is_directory == True:
            if host.file(current_location).mode == 0o775:
                continue
            else:
                assert wp_directory_permissions_flag == True
    
    assert wp_directory_permissions_flag

# tests for whether wordpress has been hardened by securing wp-config.php
## are wp-config.php permissions set to 400 ?
def test_wp_config_hardened(host):
    assert host.file("/var/www/html/wordpress/wp-config.php").mode == 0o400
