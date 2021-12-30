def test_httpd_is_running(host):
    httpd = host.service("httpd")
    assert httpd.is_running