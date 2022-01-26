def test_about_directory(host):
    about = host.file("/var/www/website/about")
    assert about.is_directory
    assert about.user == "apache"
    assert about.group == "apache"
    assert about.mode == 0o755

def test_ceo_directory(host):
    about = host.file("/var/www/website/about/our-ceo")
    assert about.is_directory
    assert about.user == "ceo"
    assert about.group == "apache"
    assert about.mode == 0o755

def test_tnc_directory(host):
    about = host.file("/var/www/website/terms-and-conditions")
    assert about.is_directory
    assert about.user == "apache"
    assert about.group == "apache"
    assert about.mode == 0o755