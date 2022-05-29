def test_httpd_is_running(host):
    httpd = host.service("httpd")
    assert httpd.is_running

def test_wp_login_is_file(host):
    wp_login = host.file("/var/www/html/wp-login.php")
    assert wp_login.is_file

def test_wp_config_is_file(host):
    wp_config = host.file("/var/www/html/wp-config.php")
    assert wp_config.is_file

def test_dir_wp_metrics(host):
    dir_wp_metrics = host.file("/var/log/wp-metrics")
    assert dir_wp_metrics.is_directory

def test_files_intervel(host):
    list_files = host.file("/var/log/wp-metrics").listdir()
    time_files = []
    delta_times = []
    for file in list_files:
        time_files.append(host.file(f"/var/log.wp-metrics/{file}").mtime)
    for i in range(len(time_files)):
        if i == 0:
            continue
        delta = time_files[i] - time_files[i-1]
        delta_times.append(delta)
    assert timedelta(seconds = 60) in delta_times
