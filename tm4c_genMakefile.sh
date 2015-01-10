###################################
#
# Auto Generate Makefile Script for ek-tm4c123gxl
# Auther: Summerslyb<Summerslyb@gmail.com>
# Version: 2015-01-10 V0.40
#
###################################
#! /bin/bash

#设置环境
MAKEFILE=$(cat /usr/share/Build_Tool/tm4c_MakefileTemplate)

#分别处理有无参数的情况
if [ -z $1 ]; then #如果没有参数
	FILES=$(find -name "*.c") #搜索目录下所有的C文件
else			   #如果有参数那么处理参数
	i=0
	declare -a FILES	#设置FILES为数组
	for ARG in $@; do
		FILES[i++]=ARG  #将$@复制到FILES中
	done
fi

#处理include依赖
for ARG in $FILES; do
	echo -e "Processing: \033[33m$ARG\033[0m"           #显示当前处理的文件
	FILE_INCLUDE=$(grep -a "#include \"" $ARG | sed -e 's/#include "\(.*\)"/\1/g' | sed -e '/inc.*$/d')  #筛选include
	DRIVERLIB=$(echo "$FILE_INCLUDE" | grep -a "driverlib")		#获得driverlib项目
	if [ -n "$DRIVERLIB" ]; then
		if [ -z "$(echo "${MAKEFILE}" | grep -a "libdriver")" ]; then 	#检查driverlib是否重复
			MAKEFILE=$(echo "${MAKEFILE}" | sed '/#_LOC_INS_/a\${COMPILER}/_PRJ_NAME_.axf: ${ROOT}/driverlib/${COMPILER}/libdriver.a')
		fi
	fi
	UTILS=$(echo "$FILE_INCLUDE" | grep -a "utils" | sed -e 's/utils\/\(.*\)\.h$/\1/g')		#获得utils项目
	for ARG2 in $UTILS; do
		if [ -n $ARG2 ]; then
			if [ -z "$(echo "${MAKEFILE}" | grep -a "$ARG2")" ]; then 	#检查utils是否重复
				MAKEFILE=$(echo "${MAKEFILE}" | sed "/#_LOC_INS_/a\\\${COMPILER}/_PRJ_NAME_.axf: \${COMPILER}/${ARG2}.o")
			fi
		fi
	done
done

#处理源文件的添加
for ARG in $FILES; do
	FILENAME=$(echo $ARG | sed 's#.*/\(.*\.c$\)#\1#g' | sed 's/\.c//g')	#获得文件名
	MAKEFILE=$(echo "${MAKEFILE}" | sed "/#_LOC_INS_/a\\\${COMPILER}/_PRJ_NAME_.axf: \${COMPILER}/${FILENAME}.o")
done

#Replace the _ROOT_DIR_
ROOT_DIR=$(pwd | sed -e "s#${HOME}\/##g" | sed 's/[^\/]*/../g' | sed 's#$#/ToolChain/TivaWare#g')
MAKEFILE=$(echo "${MAKEFILE}" | sed -e "s#_S_ROOT_DIR_#${ROOT_DIR}#g")

#Replace the _PRJ_NAME_
VAR=0
for ARG in $FILES; do
	MAIN=$(arm-none-eabi-gcc -E $ARG | grep -a "main([void]*[ ]*)[^;A-Za-z0-9]*$")
#	echo "$MAIN"
	if [ -n "$MAIN" ]; then
		FILE=$(echo $ARG | sed 's#.*/\(.*\.c$\)#\1#g' | sed 's/\.c//g')
		let "VAR=VAR+1"
	fi
done
if [ $VAR -ne 1 ]; then
	echo -e "\033[33mWe will choose *.ld as _PRJ_NAME_.\033[0m"
	LD_FILE=$(ls *.ld | sed 's#\(.*\)\.ld#\1#g')
	VAR=0
	for ARG in $LD_FILE; do
		let "VAR=VAR+1"
	done
	if [ $VAR -ne 1 ]; then
		echo -e "\033[31mCan not get the _PRJ_NAME_.\033[0m"
		exit -1
	fi
	FILE="$LD_FILE"
fi
MAKEFILE=$(echo "${MAKEFILE}" | sed -e "s/_PRJ_NAME_/${FILE}/g")

#ADD VPATH AND IPATH
for ARG in $FILES; do
	DIR=$(echo $ARG | grep -a "\.\/..*\/..*\.c" | sed 's#\(..*\)\/..*\.c#\1#g')
	if [ -n "$DIR" ]; then
		for ARG2 in $DIR; do
			if [ -z "$(echo "${MAKEFILE}" | grep -a "$ARG2")" ]; then 	#检查$DIR是否重复
				MAKEFILE=$(echo "${MAKEFILE}" | sed "/VPATH=\${ROOT}\/utils/a\\VPATH+=${ARG2}" | sed "/IPATH=\${ROOT}/a\\IPATH+=${ARG2}")
			fi
		done
	fi
done

#OUTPUT to the File
rm -rf Makefile
echo "${MAKEFILE}" > Makefile