import testinfra

def test_httpd_is_running(host):
    assert host.service("httpd").is_running

def test_wp_login_is_file(host):
    wp_login = host.file("/var/www//html/wordpress/wp-login.php")
    assert wp_login.is_file

def test_wp_config_is_file(host):
    wp_config = host.file("/var/www//html/wordpress/wp-config.php")
    assert wp_config.is_file

def test_crond_is_running(host):
    assert host.service("crond").is_running

def test_crond_is_running(host):
    assert host.service("crond").is_running
    
def test_command_dnf_crontab(host):
    with host.sudo():
        crontab = host.check_output("crontab -l")    
        assert r"""* * * * sudo dnf update""" in crontab

def test_command_shutdown_crontab(host):
    with host.sudo():
        crontab = host.check_output("crontab -l")    
        assert r"""* * * * sudo shutdown -r""" in crontab
