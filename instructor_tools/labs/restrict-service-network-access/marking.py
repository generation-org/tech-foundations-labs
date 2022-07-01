def test_httpd_is_running(host):
    httpd = host.service("httpd")
    assert httpd.is_running

def test_firewall_is_running(host):
    firewall = host.service("firewalld")
    assert firewall.is_running

def test_wp_login_is_file(host):
    wp_login = host.file("/var/www/html/wp-login.php")
    assert wp_login.is_file

def test_wp_config_is_file(host):
    wp_config = host.file("/var/www/html/wp-config.php")
    assert wp_config.is_file
