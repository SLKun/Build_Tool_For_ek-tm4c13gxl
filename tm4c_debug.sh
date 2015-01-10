###################################
#
# Auto Build and Debug for ek-tm4c123gxl
# Auther: Summerslyb<Summerslyb@gmail.com>
# Version: 2015-01-10 V0.41
#
###################################

#!/bin/bash

is_success(){
		if [ "$?" != "0" ]; then
				echo -e "\033[31mError!\033[0m"
				exit -1;
		fi
}
killopenocd(){
	OPENOCD_PID=$(ps -ef | grep -a openocd | awk '{print $2}')
	if [ -n "$OPENOCD_PID" ]; then
		kill -9 "$OPENOCD_PID"
	fi
}
addDEBUGCFLSGS(){
	sed 's/\(^CFLAGSgcc=.*$\)/\1 -O0 -g/' Makefile > Makefile_0
	\cp Makefile_0 Makefile
	rm -rf Makefile_*
}

# 初始化
killopenocd
declare MAKEFILE_ORIGINAL
if [ -f Makefile ]; then
	MAKEFILE_ORIGINAL=$(cat Makefile)
fi
# 生成Makefile
tm4c_genMakefile.sh
is_success
addDEBUGCFLSGS
MAKEFILE=$(cat Makefile)
if [ "$MAKEFILE" != "$MAKEFILE_ORIGINAL" ]; then
	make clean
	is_success
fi
# 编译
make
is_success
# 启动OpenOCD
echo -e "\033[33mLoading OPENOCD...\033[0m"
openocd --file ~/ToolChain/openocd/ek-tm4c123gxl.cfg >> openocd_log 2>&1 &
sleep 1s
ISERROR_OPENOCD=$(grep -a "Error" openocd_log)
if [ -n "$ISERROR_OPENOCD" ]; then
	echo -e "\033[31m===========Error Message===========\033[0m"
	cat openocd_log
	exit -1;
fi
# 启动GDB
PRJNAME=$(grep -a "the Project Name" Makefile | sed 's#\#\(.*\) = the Project Name$#\1#g')
rm -rf gdbprecmd
sed "s/_PRJ_NAME_/${PRJNAME}/g" /usr/share/Build_Tool/tm4c_gdbprecmdTemplate >> gdbprecmd
echo -e "\033[33mLoading GDB...\033[0m"
arm-none-eabi-gdb -x gdbprecmd -quiet gcc/${PRJNAME}.axf
# 结束调试时关掉OpenOCD
killopenocd
rm -rf gdbprecmd openocd_log
tm4c_update.sh &