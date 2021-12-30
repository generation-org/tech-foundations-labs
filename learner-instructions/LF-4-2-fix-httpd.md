# Fix a server - Fix httpd

_Small edits to big files can be the difference between something working and not.._

The configuration file. Long, boring lists of key-value pairs, telling the software it's paired with how to run. Unlike the previous task, you may spend quite a lot of time diving into configuration files and making small changes to tweak performance or fix problems. So it pays to get used to this kind of thing now.

We have deployed some html files to the directories you created in Task 3 - now all you need to do is **tell httpd where to find the website**. Httpd, the web server, is currently pointing to a default location - but with your Google skills and your deft hand searching and editing files, this should be within your grasp.

(Remember - whenever you change httpd's configuration you'll need to restart it. Oh, we haven't taught you how to restart services yet.. huh. You'll work it out.)

## Goals

1. Edit httpd's configuration to point to `/var/www/website` instead of the current default
1. Restart httpd to make it load the new configuration
1. Browse to the IP address of your server to check the new website is there

## Extra time

Man, that's an ugly website - can you make it better? I heard it's all just HTML written out in text files..
