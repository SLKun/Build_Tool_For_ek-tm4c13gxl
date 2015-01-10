###################################
#
# Auto Build and Flash for ek-tm4c123gxl
# Auther: Summerslyb<Summerslyb@gmail.com>
# Version: 2015-01-10 V0.40
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
# 初始化
killopenocd
declare MAKEFILE_ORIGINAL
if [ -f Makefile ]; then
	MAKEFILE_ORIGINAL=$(cat Makefile)
fi
# 生成Makefile
tm4c_genMakefile.sh
is_success
MAKEFILE=$(cat Makefile)
if [ "$MAKEFILE" != "$MAKEFILE_ORIGINAL" ]; then
	make clean
	is_success
fi
# 编译
make
is_success
# 烧写
if [ -n "$(LMFlash --usbdevices)" ]; then
	PRJNAME=$(grep -a "the Project Name" Makefile | sed 's#\#\(.*\) = the Project Name$#\1#g')
	LMFlash --quick-set=ek-tm4c123gxl --verify --reset gcc/${PRJNAME}.bin
	echo -e "\033[31m\033[0m"
	echo -e "\033[32mFinished!\033[0m"
else
	echo -e "\033[31mYou haven't insert the devices!\033[0m"
fi
tm4c_update.sh &