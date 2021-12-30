# Technical Accuracy - Create some directories

_Demonstrate dilligence and accuracy - computers are very literal!_

It is not common for engineers to spend their days creating directories from lists. Once, it was - automation of manual and laborious tasks has become a big feature of the modern "DevOps" mindset. But it's not likely you'll be given exactly this task in the real world. However, this task demands something of you that every employer will expect - precision.

**You have below a list of directories, which must be created with the exact names, ownership and permissions set out alongside them.** They have been listed out as prose, so you might first want to organise them before getting to work. This isn't very hard, and you've been given the knowledge and tools in the lesson (unlike your last task). But we're looking here for you to be accurate, so ensure you pay attention to what you're doing - and check your work!

> "Hey, are you the server guy? Okay, so I want some new folders on the web server. Firstly we need a terms and conditions folder - don't use spaces, you should use dashes instead. And we also need an about folder. All these folders need to be written in lower-case, alright? And inside that about folder we also need one called our ceo - so we can talk about our CEO, he'll love that. Dashes, not spaces! And all these need to be owned by the httpd user and group, except the our ceo folder which needs to be owned by the ceo user. But still the httpd group, or it won't work! And all the permissions need to be seven five five, alright? I'll leave it with you, you've got this buddy!"

## Goals

1. Create all the directories listed
1. Set the file ownership and permissions on all the directories as listed
1. Validate your work to ensure it is accurate

## Extra time

Can you create a new folder, `/var/www/website-mirror`, and mirror all the folders from `/var/www/website`? How might you do this?
