#!/bin/bash


#Allow apps to install
sudo spctl --master-disable

#Asks for the name of the new user

#log in name (uppercase first letter)
read -p "Enter Real Name: "  realname

#terminal name (lowercase first letter)
read -p "Enter Username: "  username

#Computer Name
read -p "Enter Computer Name: "  computername

#Create the User's Account
sudo dscl . -create /Users/$username
sudo dscl . -create /Users/$username UserShell /bin/bash
sudo dscl . -create /Users/$username RealName "$realname" 
sudo dscl . -create /Users/$username UniqueID "510"
sudo dscl . -create /Users/$username PrimaryGroupID 20
sudo dscl . -create /Users/$username NFSHomeDirectory /Users/$username
sudo dscl . -passwd /Users/$username Welcome123
sudo fdesetup add -usertoadd $username -p -keychain Welcome123
sudo dscl . -append /Groups/admin GroupMembership $username

# Changes the name of the computer
sudo scutil --set ComputerName $computername
sudo scutil --set LocalHostName $computername
sudo scutil --set HostName $computername

# Install Chrome, meraki, and zoom

#Let stuff install

#sleep 30

#sudo installer -pkg ~/Downloads/newmac/zoomusInstaller.pkg -target /

#sudo installer -pkg ~/Downloads/newmac/Chrome-65.0.3325.181.pkg -target /

#sudo installer -pkg ~/Downloads/newmac/Slack-3.1.0.pkg -target /


