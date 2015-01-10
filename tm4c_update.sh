###################################
#
# Update for Build_Tool
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
UPDATE_DATE_LAST=$(grep "UPDATE_DATE" ${CONFIG} | sed 's/UPDATE_DATE *= *\([0-9]\{4\}[0-9]\{2\}[0-9]\{2\}\)/\1/g')

is_success(){
		if [ "$?" != "0" ]; then
				echo -e "\033[31mError!\033[0m"
				exit -1;
		fi
}
getVersion(){
	wget --quiet "https://raw.githubusercontent.com/Summerslyb/Build_Tool_For_ek-tm4c13gxl/stable/version" -O ${WORKDIR}/version
	is_success
	NEW_VERSION=$(cat ${WORKDIR}/version)
	OLD_VERSION=$(cat ${DATADIR}/version)
}
update(){
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
}


mkdir -p ${WORKDIR}
if [ ${DATE_NOW} -gt ${UPDATE_DATE_LAST} ]; then	# 比较升级日期与当前日期
# if [ true ]; then
	getVersion
	if [ ${OLD_VERSION} != ${NEW_VERSION} ]; then	# 比较版本是否发生变化
	# if [ true ]; then
		echo -e "\033[33m============================================\033[0m"
		echo -e "Info: \033[33mNEED UPDATE!\033[0m"
		update
	fi
fi
rm -rf ${WORKDIR}