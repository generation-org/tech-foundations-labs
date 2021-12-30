def test_documentroot(host):
    httpdconf = host.file("/etc/httpd/httpd.conf")
    assert httpdconf.contains("/var/www/website")

def test_httpd_starts(host):
    host.ansible("service", "name=httpd state=restarted", check=False, become=True)