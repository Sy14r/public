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
webMethod=$(which curl)
if [ $? -eq 1 ]
then
	webMethod=$(which wget)
fi

# Download the newest (stable) version of go - and check if we already have go
# if so abort for now, in future provide upgrade functionality
if [ $(echo $webMethod | grep 'curl') ]
then
	echo [+] Finding newest version of Go
	downloadLoc=$($webMethod -s $url | egrep -i "href.*$os.*$arch" | egrep -v "rc" | head -1 | cut -d'=' -f3 | tr -d '>' | tr -d '"')

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
	$webMethod -s $downloadLoc -o golang.tar.gz
elif [ $(echo $webMethod | grep 'wget') ]
then
	echo [X] WGET not yet implemented
	exit
else
	echo [X] No support web methods found... exiting
	exit
fi

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
