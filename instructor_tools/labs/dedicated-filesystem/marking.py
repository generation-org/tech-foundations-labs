def test_filesystem_db(host):
    filesystem_db = host.check_output("df -Th")
    assert "db" in filesystem_db 

def test_httpd_is_running(host):
    httpd = host.service("httpd")
    assert httpd.is_running

def test_wp_login_is_file(host):
    wp_login = host.file("/u01/wordpress/wp-login.php")
    assert wp_login.is_file

def test_wp_config_is_file(host):
    wp_config = host.file("/u01/wordpress/wp-config.php")
    assert wp_config.is_file
