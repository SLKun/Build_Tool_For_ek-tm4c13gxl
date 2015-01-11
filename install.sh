###################################
#
# Online Install Script for Build_Tool
# Auther: Summerslyb<Summerslyb@gmail.com>
# Version: 2015-01-10 V0.40
#
###################################
#!/bin/bash

WORKDIR=/tmp/Build_Tool
PROGRAMDIR=/usr/bin
DATADIR=/usr/share/Build_Tool
CONFIG=/etc/tm4c.conf
DATE_NOW=$(date +%Y%m%d)

is_success(){
		if [ "$?" != "0" ]; then
				echo -e "\033[31mError!\033[0m"
				exit -1;
		fi
}

mkdir -p ${WORKDIR}
echo -e "\033[33m============================================\033[0m"
echo -e "Info: \033[33mDownloading files from the Internet...\033[0m"  
wget -nv --show-progress "https://github.com/Summerslyb/Build_Tool_For_ek-tm4c13gxl/archive/stable.zip" -O ${WORKDIR}/Build_Tool.zip
is_success
echo -e "Info: \033[33mDecompressing files...\033[0m"  
7z x ${WORKDIR}/Build_Tool.zip -o${WORKDIR} >> ${WORKDIR}/7z_log
is_success
chmod +x ${WORKDIR}/Build_Tool_For_ek-tm4c13gxl-stable/*.sh
echo -e "Info: \033[33mInstalling files...\033[33m"  
mv ${WORKDIR}/Build_Tool_For_ek-tm4c13gxl-stable/tm4c_*.sh ${PROGRAMDIR}
mkdir -p /usr/share/Build_Tool
mv ${WORKDIR}/Build_Tool_For_ek-tm4c13gxl-stable/* ${DATADIR}
# 写入新的UPDATE_DATE
if [ -s ${CONFIG} ]; then
	BUFFER=$(grep "UPDATE_DATE" ${CONFIG} | sed "s/\(UPDATE_DATE *= *\)[0-9]\{4\}[0-9]\{2\}[0-9]\{2\}/\\1${DATE_NOW}/g")
	rm -rf ${CONFIG}
else
	BUFFER="UPDATE_DATE = ${DATE_NOW}"
fi
echo "${BUFFER}" > ${CONFIG}
echo -e "\033[33m============================================\033[0m"
rm -rf ${WORKDIR}
