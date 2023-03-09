This is part of a guide to deploy a Minecraft Server running on AKS. 
A File Share will be mounted on the container to keep your installation files, configurations, and worlds safe and accessible. 
The file share will allow you to also mount the Share as a Network Drive on your local PC if you would like to move worlds and other files around. 
You can also use the Cronjob to automatically restart the container on specific dates/times which will trigger an automatic update of the Minecraft Server if one is available. 