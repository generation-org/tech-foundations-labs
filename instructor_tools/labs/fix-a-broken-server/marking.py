import requests

def test_documentroot(host):
    httpdconf = host.file("/etc/httpd/httpd.conf")
    assert httpdconf.contains("/var/www/website")
    assert httpdconf.contains("Listen 80")

def test_vandals(host):
    response = requests.get("https://localhost")
    assert response.content.contains("Our Website")

def test_httpd_starts(host):
    host.ansible("service", "name=httpd state=restarted", check=False, become=True)

def test_ssh_is_22(host):
    sshdconf = host.file("/etc/ssh/sshd_config")
    assert sshdconf.contains("Port 22")
