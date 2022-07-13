def test_wp_login_is_file(host):
    wp_login = host.file("/var/www/html/wp-login.php")
    assert wp_login.is_file

def test_wp_config_is_file(host):
    wp_config = host.file("/var/www/html/wp-config.php")
    assert wp_config.is_file

def test_user_wordpress_httpd(host):
    httpd_wordpress = host.user("wordpress").check_output("systemctl --user status httpd")
    assert r"running" in https_wordpress
