#/bin/sh

echo "----------"
echo "Script created by https://github.com/pecrow" 
echo "You may modify and use this as needed. Only to be distrubuted at no cost. If modifying or posting elsewhere, please link to this github."
#NOTE: This script bypases the "I Agree" checkbox for Minecraft's End User License Agreement and Privacy Policy which is a mandatory check under https://www.minecraft.net/en-us/download/server/bedrock to download these files. By using this script you agree with both of Minecraft's End User License Agreement and Privacy Policy. 
echo "----------"

echo "$(date) - Creating required directories and files."
mkdir /home/Minecraft/tmp 2>/dev/null
mkdir /home/Minecraft/MinecraftServer_Bedrock 2>/dev/null
mkdir /home/Minecraft/MinecraftServer_Backup 2>/dev/null
## This file is used to check if version should be updated. 
touch /home/Minecraft/Last_Mine-version 2>/dev/null 

echo "$(date) - Installing wget, curl, bash-static, and unzip packages"
export DEBIAN_FRONTEND=noninteractive >/dev/null
apt-get -y update >/dev/null
apt-get install -y --no-install-recommends --no-install-suggests --fix-missing bash-static wget unzip curl >/dev/null

echo "$(date) - Preparing and exporting the URL for the Minecraft Bedrock Server files."
URL=$(curl -k "https://www.minecraft.net/en-us/download/server/bedrock" -H "Accept-Encoding: gzip,deflate,sdch" -H "Accept-Language: en-US,en;q=0.8" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Referer: http://google.com"-H "Connection: keep-alive" -H "Cache-Control: max-age=0" --compressed >/home/Minecraft/tmp/bedrock 2>/dev/null; echo $(cat /home/Minecraft/tmp/bedrock | grep bin-linux | awk '{print $2}' |sed 's/href=//' | tr -d '"' ))

echo "$(date) - Performing basic file cleanup, removing garbage files if they exist to save space."
rm -fv /home/Minecraft/MinecraftServer_Bedrock/*.zip 2>/dev/null
rm -fv /home/Minecraft/MinecraftServer_Bedrock/bedrock_server_symbols.debug 2>/dev/null

echo "$(date) - Backing up server.properties, whitelist.json, and permissions.json if they exist." 
cp -v /home/Minecraft/MinecraftServer_Bedrock/server.properties /home/Minecraft/MinecraftServer_Backup 2>/dev/null
cp -v /home/Minecraft/MinecraftServer_Bedrock/whitelist.json /home/Minecraft/MinecraftServer_Backup 2>/dev/null
cp -v /home/Minecraft/MinecraftServer_Bedrock/permissions.json /home/Minecraft/MinecraftServer_Backup 2>/dev/null
echo "$(date) - Backing up existing worlds if they exist." 
cp -vr /home/Minecraft/MinecraftServer_Bedrock/worlds/ /home/Minecraft/MinecraftServer_Backup/worlds/ 2>/dev/null

echo "$(date) - Comparing the latest and currently installed Minecraft versions."
if echo $URL | grep -q $(cat /home/Minecraft/Last_Mine-version)  2>/dev/null ; then
   echo "$(date) - Current Minecraft version is $(cat /home/Minecraft/Last_Mine-version | awk -F'/' '{print $5}' )"
   echo "$(date) - Already on latest version, starting the Minecraft server! Note this will take a few minutes." 
   cd /home/Minecraft/MinecraftServer_Bedrock/ && LD_LIBRARY_PATH=. ./bedrock_server 
   echo "$(date) - Yay! All set, have fun." 
   exit 1
else
   echo "$(date) - A fresh or outdated Minecraft version has been detected."
   echo "$(date) - Updating Minecraft to the latest version."
   echo "$(date) - Downloading latest Bedrock version $( echo $URL | awk -F'/' '{print $5}') "
   wget --quiet $URL -P /home/Minecraft/MinecraftServer_Bedrock --no-check-certificate 2>/dev/null
   echo "$(date) - Download finished, extracting files now. It will take time to complete."
   echo "$(date) - Verbosity has been turned off so don't freak out, things are running, go get a coffee!"
   unzip -o /home/Minecraft/MinecraftServer_Bedrock/bedrock-server*.zip -d /home/Minecraft/MinecraftServer_Bedrock/ >/dev/null
   ### Sometimes the bedrock_server file doesn't get extracted from the zip for some reason so this is a second attempt just in case.
   unzip -p /home/Minecraft/MinecraftServer_Bedrock/bedrock-server*.zip bedrock_server > /home/Minecraft/MinecraftServer_Bedrock/bedrock_server 
   echo "$(date) - Update complete." 
   echo "$(date) - Restoring server.properties, whitelist.json, and permissions.json."
   cp -v /home/Minecraft/MinecraftServer_Backup/server.properties /home/Minecraft/MinecraftServer_Bedrock 2>/dev/null
   cp -v /home/Minecraft/MinecraftServer_Backup/whitelist.json /home/Minecraft/MinecraftServer_Bedrock 2>/dev/null
   cp -v /home/Minecraft/MinecraftServer_Backup/permissions.json /home/Minecraft/MinecraftServer_Bedrock 2>/dev/null
   echo "$(date) - Writing down latest updated version for future checks." 
	 echo $URL > /home/Minecraft/Last_Mine-version
   echo "$(date) - Starting the Minecraft server! Almost there..."
   cd /home/Minecraft/MinecraftServer_Bedrock/ && LD_LIBRARY_PATH=. ./bedrock_server
   echo "$(date) - Yay! All set, have fun." 
fi
## Due to the nature of this configuration, since I am calling the script via the yaml file to be executed on every container start, when the script ends the container will be restarted. 
## Just putting this sleep here to prevent it. Going the simple/lazy route. 
## Also, I could add a loop to check for updates in here, but I'd rather show you how to create cronjobs in AKS which is more fun ;] after all we're here to learn. Make sure you check out the guide soon to be posted under https://ramirez.cr . 
## PS:  If you don't want to set up a Cron Job to restart the container simply change the seconds in this sleep to something smaller.
sleep 100000000