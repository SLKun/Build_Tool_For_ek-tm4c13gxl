###################################
#
# Auto Generate Makefile Script for ek-tm4c123gxl
# Auther: Summerslyb<Summerslyb@gmail.com>
# Version: 2015-01-09 V0.22
#
###################################
#! /bin/bash

#设置环境
set +o noclobber
rm -rf Makefile Makefile_*
\cp tm4c_MakefileTemplate Makefile
#分别处理有无参数的情况
if [ -z $1 ]; then #如果没有参数
#	FILES=$(ls *.c)
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
	VAR=0               #中间缓冲变量
	\cp Makefile Makefile_${VAR} #初始化缓冲区
	FILE_INCLUDE=$(grep -a "#include \"" $ARG | sed -e 's/#include "\(.*\)"/\1/g' | sed -e '/inc.*$/d')  #筛选include
#	echo "---${FILE_INCLUDE}"
	#获得driverlib项目
	DRIVERLIB=$(echo "$FILE_INCLUDE" | grep -a "driverlib")
	if [ -n "$DRIVERLIB" ]; then
		if [ -z "$(grep -a "libdriver" Makefile_${VAR})" ]; then #检查driverlib是否已经存在
			sed '/#_LOC_INS_/a\${COMPILER}/_PRJ_NAME_.axf: ${ROOT}/driverlib/${COMPILER}/libdriver.a' Makefile_${VAR} > Makefile_$((VAR=VAR+1))
			let "VAR=VAR+1"
		fi
	fi
	#获得utils项目
	UTILS=$(echo "$FILE_INCLUDE" | grep -a "utils" | sed -e 's/utils\/\(.*\)\.h$/\1/g')	
	for ARG2 in $UTILS; do
		if [ -n $ARG2 ]; then
			if [ -z "$(grep -a "$ARG2" Makefile_${VAR})" ]; then #检查utils是否已经存在
				sed "/#_LOC_INS_/a\\\${COMPILER}/_PRJ_NAME_.axf: \${COMPILER}/${ARG2}.o" Makefile_${VAR} > Makefile_$((VAR=VAR+1))
				let "VAR=VAR+1"
			fi
		fi
	done
	#收尾工作
	\cp Makefile_${VAR} Makefile
	rm -rf Makefile_*
done
#处理源文件的添加
rm -rf Makefile_*
for ARG in $FILES; do
	FILE=$(echo $ARG | sed 's#.*/\(.*\.c$\)#\1#g' | sed 's/\.c//g')	#获得文件名
	if [ -f ./Makefile ]; then
		sed "/#_LOC_INS_/a\\\${COMPILER}/_PRJ_NAME_.axf: \${COMPILER}/${FILE}.o" Makefile > Makefile_0
		\cp Makefile_0 Makefile
		rm -rf Makefile_*
	fi
done
#Replace the _ROOT_DIR_
ROOT_DIR=$(pwd | sed -e "s#${HOME}\/##g" | sed 's/[^\/]*/../g' | sed 's#$#/ToolChain/TivaWare#g')
sed -e "s#_S_ROOT_DIR_#${ROOT_DIR}#g" Makefile > Makefile_0
\cp Makefile_0 Makefile
rm -rf Makefile_*
#Get the MAIN
VAR=0
for ARG in $FILES; do
	MAIN=$(arm-none-eabi-gcc -E $ARG | grep -a "main(void)[^;A-Za-z0-9]*$")
#	echo "$MAIN"
	if [ -n "$MAIN" ]; then
		FILE=$(echo $ARG | sed 's#.*/\(.*\.c$\)#\1#g' | sed 's/\.c//g')
		let "VAR=VAR+1"
	fi
done
#Examine multi MAIN
if [ $VAR -ne 1 ]; then
	echo -e "\033[33mWe will choose *.ld as _PRJ_NAME_.\033[0m"
	LD_FILE=$(ls *.ld | sed 's#\(.*\)\.ld#\1#g')
	VAR=0
	for ARG in $LD_FILE; do
		let "VAR=VAR+1"
	done
	#Examine multi LD
	if [ $VAR -ne 1 ]; then
		echo -e "\033[31mCan not get the _PRJ_NAME_.\033[0m"
		exit -1
	fi
	FILE="$LD_FILE"
fi
#Replace the _PRJ_NAME_
sed -e "s/_PRJ_NAME_/${FILE}/g" Makefile > Makefile_0
\cp Makefile_0 Makefile
rm -rf Makefile_*
#ADD VPATH AND IPATH
for ARG in $FILES; do
	DIR=$(echo $ARG | grep -a "\.\/..*\/..*\.c" | sed 's#\(..*\)\/..*\.c#\1#g')
	if [ -n "$DIR" ]; then
		VAR=0
		\cp Makefile Makefile_${VAR}
		for ARG2 in $DIR; do
			sed "/VPATH=\${ROOT}\/utils/a\\VPATH+=${ARG2}" Makefile_${VAR} | sed "/IPATH=\${ROOT}/a\\IPATH+=${ARG2}" > Makefile_$((VAR=VAR+1))
			let "VAR=VAR+1"
		done
		\cp Makefile_${VAR} Makefile
		rm -rf Makefile_*
	fi
done
