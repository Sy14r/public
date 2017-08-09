#!/bin/bash
# webMethod 	- binary to use for downloading
# os 		- linux/bsd/osx...(only linux support at the moment) 
# arch		- 32/64 bit distinction for now

# First verify that we are on a supported OS
if [ $(uname -o | grep -i 'linux') ]
then
	os='linux'
else
	os='unk'
	echo "Unsupported OS detected"
	exit
fi

# Determine the appropriate architecture
if [ $(uname -p | grep 'x86_64') ]
then
	arch='64'
else
	arch='32'
fi

url='https://golang.org/dl/'

# Determine which utility will provide web access
webMethod=''
webFlags=''
if [ $(which curl) ]
then
	webMethod=$(which curl)
	webFlags='-s'
elif [ $(which wget) ]
then
	webMethod=$(which wget)
	webFlags='-qO-'
else
	echo "[X] No supported web methods found (curl, wget)"
	exit
fi

# Download the newest (stable) version of go - and check if we already have go
# if so abort for now, in future provide upgrade functionality
echo [+] Finding newest version of Go
downloadLoc=$($webMethod $webFlags $url | egrep -i "href.*$os.*$arch" | egrep -v "rc" | head -1 | cut -d'=' -f3 | tr -d '>' | tr -d '"')

# Check if this is a fresh install or potential upgrade
if [ $(which go) ]
then
	currVer=$(go version | cut -d' ' -f3)
	if [ $(echo $downloadLoc | egrep $currVer.$os) ]
	then
		echo [\!] Already have newest version
	else
		echo [\!] Newer version available
		echo [X] Upgrade not yet implemented
		exit
	fi
fi

# first download the installer
echo [+] Downloading Go

if [ $(echo $webMethod | grep 'curl') ]
then
	webFlags='-so'
else
	webFlags='-qO'
fi

$webMethod $webFlags golang.tar.gz $downloadLoc

# Install Go
echo [+] Installing Go
tar -C /usr/local -xzf golang.tar.gz
rm golang.tar.gz

# Modify the PATH env variable if necessary
if [ "$(grep '/usr/local/go/bin' $HOME/.bash_profile)" == "" ]
then
	# and add the export for new PATH (if needed)
	echo export PATH=\$PATH:/usr/local/go/bin >> $HOME/.bash_profile
	. $HOME/.bash_profile
fi

echo [+] Installation Complete
