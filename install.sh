#!/bin/bash

rm -rf stable.zip Build_Tool
echo -e "\033[33mDownloading files from the Internet...\033[0m"  
wget https://github.com/Summerslyb/Build_Tool_For_ek-tm4c13gxl/archive/stable.zip
echo -e "\033[33mDecompressing files...\033[0m"  
7z x stable.zip
mv Build_Tool_For_ek-tm4c13gxl-stable Build_Tool
chmod +x Build_Tool/*.sh
echo -e "\033[33mInstalling files...\033[0m"  
mv Build_Tool/*.sh /usr/bin
if [ -d "/usr/share/Build_Tool/" ]; then
	DIRECTORY_IS_EXIST=1
else
	DIRECTORY_IS_EXIST=0
	mkdir /usr/share/Build_Tool
fi
mv Build_Tool/* /usr/share/Build_Tool
rm -rf stable.zip Build_Tool install.sh