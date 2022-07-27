import testinfra

## Tests for whether WordPress is deployed and being served
# Is WordPress deployed?
def test_wp_login_is_file(host):
    wp_login = host.file("/var/www/html/wordpress/wp-login.php")
    assert wp_login.is_file

# Is httpd serving WordPress?
def test_httpd_serving_wordpress(host):
    assert host.run('curl -f http://localhost/wp-login.php').rc == 0

## Tests for whether tar backups are being kept in /backups/
# file exists /backups/wordpress.tar.gz or bz2 or xz or zst etc
def test_does_wordpress_tar_exist(host):
    file_found = True
    if host.file("/backups/wordpress.tar.gz").exists:
        pass
    elif host.file("/backups/wordpress.tar.bz2").exists:
        pass
    elif host.file("/backups/wordpress.tar.zst").exists:
        pass
    elif host.file("/backups/wordpress.tar.lzma").exists:
        pass
    elif host.file("/backups/wordpress.tar.lzo").exists:
        pass
    elif host.file("/backups/wordpress.tar.lz").exists:
        pass
    elif host.file("/backups/wordpress.tar.xz").exists:
        pass
    elif host.file("/backups/wordpress.tar.Z").exists:
        pass
    else:
        file_found = False
    assert file_found

# inspect the archive to ensure files are present with the correct permissions
def test_output_of_tar_xf(host):
    wp_tar_permissions_flag = True
    file_found = True
    if host.file("/backups/wordpress.tar.gz").exists:
        file_type = "gz"
    elif host.file("/backups/wordpress.tar.bz2").exists:
        file_type = "bz2"
    elif host.file("/backups/wordpress.tar.zst").exists:
        file_type = "zst"
    elif host.file("/backups/wordpress.tar.lzma").exists:
        file_type = "lzma"
    elif host.file("/backups/wordpress.tar.lzo").exists:
        file_type = "lzo"
    elif host.file("/backups/wordpress.tar.lz").exists:
        file_type = "lz"
    elif host.file("/backups/wordpress.tar.xz").exists:
        file_type = "xz"
    elif host.file("/backups/wordpress.tar.Z").exists:
        file_type = "Z"
    else:
        file_found = False

    if file_found == True:
        tar_extract_command = "cd /backups/testing; tar xpf /backups/wordpress.tar." + file_type

        with host.sudo():
            host.run("mkdir /backups/testing").rc
            host.run(tar_extract_command).rc

        for each_wordpress_file in host.file("/backups/testing/wordpress/").listdir():
            wordpress_location = "/backups/testing/wordpress/" + each_wordpress_file

            if host.file(wordpress_location).is_directory == True:
                if host.file(wordpress_location).mode != 0o755:
                    wp_tar_permissions_flag = False
                    break
            elif host.file(wordpress_location).is_file == True:
                if host.file(each_wordpress_file) != 'wp-config.php':
                    if host.file(wordpress_location).mode != 0o644:
                        wp_tar_permissions_flag = False
                        break

            if (wp_tar_permissions_flag == False):
                break
    else:
        wp_tar_permissions_flag = False

    assert wp_tar_permissions_flag

## Tests for whether tar archives are being automated in crontab
# check crontab -l
def test_is_there_a_tar_schedule(host):
    scheduled_tar = True
    with host.sudo():
        if (host.file("/var/spool/cron/root").exists == True):
            cron_tar_list = host.file("/var/spool/cron/root").content_string
            cron_tar_list = cron_tar_list + '\n'

            if '59 23 * * 5 ' not in cron_tar_list:
                scheduled_tar = False
            else:
                tar_command = cron_tar_list.split('59 23 * * 5 ')[-1].split('\n')[0]
                host.run("rm /backups/wordpress.tar.*")
                host.run(tar_command).rc
                if host.file("/backups/wordpress.tar.gz").exists:
                    scheduled_tar = True
                elif host.file("/backups/wordpress.tar.bz2").exists:
                    scheduled_tar = True
                elif host.file("/backups/wordpress.tar.zst").exists:
                    scheduled_tar = True
                elif host.file("/backups/wordpress.tar.lzma").exists:
                    scheduled_tar = True
                elif host.file("/backups/wordpress.tar.lzo").exists:
                    scheduled_tar = True
                elif host.file("/backups/wordpress.tar.lz").exists:
                    scheduled_tar = True
                elif host.file("/backups/wordpress.tar.xz").exists:
                    scheduled_tar = True
                elif host.file("/backups/wordpress.tar.Z").exists:
                    scheduled_tar = True
                else:
                    scheduled_tar = False
        else:
            scheduled_tar = False

    assert scheduled_tar

## extra credit test for rsync directory synching in crontab
def test_is_there_an_rsync_schedule(host):
    scheduled_rsync = True
    with host.sudo():
        if (host.file("/var/spool/cron/root").exists == True):
            cron_rsync_list = host.file("/var/spool/cron/root").content_string
            cron_rsync_list = cron_rsync_list + '\n'

            if '0 3 * * 1 ' not in cron_rsync_list:
                rsync_command = False
            else:
                rsync_command = cron_rsync_list.split('0 3 * * 1 ')[-1].split('\n')[0]
                host.run("rm -r /backups/wordpress").rc
        else:
            rsync_command = False

        if rsync_command != False:
            host.run(rsync_command).rc
        else:
            scheduled_rsync = False

        wordpress_dir = '/backups/wordpress/'

        for each_file in host.file(wordpress_dir).listdir():
            current_location = wordpress_dir + each_file
            if each_file != "wp-config.php":
                if host.file(current_location).is_file == True:
                    if host.file(current_location).mode != 0o644:
                        scheduled_rsync = False
                elif host.file(current_location).is_directory == True:
                    if host.file(current_location).mode != 0o755:
                        scheduled_rsync = False

    assert scheduled_rsync

# tests for whether backed up wordpress has been hardened by securing wp-config.php
## are wp-config.php permissions in synched directory set to 400 ?
def test_synched_wp_config_hardened(host):
    with host.sudo():
        assert host.file("/backups/wordpress/wp-config.php").mode == 0o400