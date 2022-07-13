def test_documentroot(host):
    httpdconf = host.file("/etc/httpd/conf/httpd.conf")
    assert httpdconf.contains("Listen 80")

def test_httpd_starts(host):
    host.ansible("service", "name=httpd state=restarted", check=False, become=True)