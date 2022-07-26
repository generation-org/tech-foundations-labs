import testinfra

## Tests for whether WordPress is deployed and being served
# Is WordPress deployed?
def test_wp_login_is_file(host):
    wp_login = host.file("/var/www/html/wordpress/wp-login.php")
    assert wp_login.is_file

# Is httpd serving WordPress?
def test_httpd_serving_wordpress(host):
    assert host.run('curl -f http://localhost/login').rc == 0

## Tests for whether tar backups are being kept in /backups/
# file exists /backups/wordpress.tar.gz or bz2 or xz or zst etc
def test_does_wordpress_tar_exist(host):
    root_directory_list = host.file("/backups/").listdir()
    compression_algorithms = ['gz','bz2','xz','zst','lz','lzma','lzo']
    
    result any(element in root_directory_list for element in compression_algorithms)

    assert result

# inspect the archive to ensure files are present with the correct permissions
def test_output_of_tar_xf(host):
    wp_tar_permissions_flag = 

    for each_file in host.file("/backups/").listdir():
        current_location = '/backups/' + each_file

        if '.tar.' in each_file:
            host.run('mkdir /backups/testing && tar xf current_location -C /backups/testing').rc

        for each_file in host.file("/backups/testing/wordpress/").listdir():
            wordpress_location = '/backups/testing/wordpress/' + each_wordpress_file

            if host.file(wordpress_location).is_directory == True:
                if host.file(wordpress_location).mode != 0o755:
                    wp_tar_permissions_flag = False
                    break
            elif host.file(wordpress_location).is_file == True:
                if host.file(wordpress_location).mode != 0o644:
                    wp_tar_permissions_flag = False
                    break

            if (wp_tar_permissions_flag == False):
                break
    
    assert wp_tar_permissions_flag


## Tests for whether tar archives are being automated in crontab or systemd timers
# check crontab -l or systemctl show
def test_is_there_a_tar_schedule(host):
    if (host.file("/var/spool/cron/root").exists == True):
        cron_tar_list = host.file("/var/spool/cron/root").content_string
        cron_tar_list = cron_tar_list + '\n'
        if '59 23 * * 5 ' not in cron_tar_list:
            scheduled_tar = False
        else:
            tar_command = cron_tar_list.split('59 23 * * 5 ')[-1].split('\n')[0]
            host.run(tar_command).rc
            type_of_file = host.run('file wordpress.*').check_output
            if 'POSIX tar archive (GNU)' not in type_of_file:
                scheduled_tar = False
            else:
                scheduled_tar = True
    else:
        scheduled_tar = False

assert scheduled_tar

## extra credit test for rsync directory
def test_is_there_an_rsync_schedule(host):
    if (host.file("/var/spool/cron/root").exists == True):
        cron_rsync_list = host.file("/var/spool/cron/root").content_string
        cron_rsync_list = cron_rsync_list + '\n'
        if '0 3 * * 1 ' not in cron_rsync_list:
            scheduled_rsync = False
        else:
            rsync_command = cron_rsync_list.split('0 3 * * 1 ')[-1].split('\n')[0]
            host.run(rsync_command).rc

    wp_permissions_flag = True
    wordpress_dir = '/backups/wordpress/'

    for each_file in host.file(wordpress_dir).listdir():
        current_location = wordpress_dir + each_file
        if each_file != "wp-config.php":
            if host.file(current_location).is_file == True:
                if host.file(current_location).mode != 0o644:
                    wp_permissions_flag = False

    for each_file in host.file(wordpress_dir).listdir():
        current_location = wordpress_dir + each_file

        if host.file(current_location).is_directory == True:
            if host.file(current_location).mode == 0o755:
                continue
            else:
                wp_permissions_flag = False

    assert wp_permissions_flag

# tests for whether wordpress has been hardened by securing wp-config.php
## are wp-config.php permissions set to 400 ?
def test_rsync_wp_config_hardened(host):
    assert host.file("/backups/wordpress/wp-config.php").mode == 0o400