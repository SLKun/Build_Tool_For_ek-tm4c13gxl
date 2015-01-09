###################################
#
# Auto Build and Debug for ek-tm4c123gxl
# Auther: Summerslyb<Summerslyb@gmail.com>
# Version: 2015-01-09 V0.22
#
###################################

#!/bin/bash

check(){
		if [ "$?" != "0" ]; then
				echo -e "\033[31mError!\033[0m"
				exit -1;
		fi
}
getprjname(){
	PRJNAME=$(grep -a "the Project Name" Makefile | sed 's#\#\(.*\) = the Project Name$#\1#g')
}
diff(){
	DIFF=$(awk '{print $0}' Makefile Makefile.tmp | sort | uniq -u)
	rm -rf Makefile.tmp
}
getopenocdpid(){
	OPENOCD_PID=$(ps -ef | grep -a openocd | awk '{print $2}')
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

#Prepare
killopenocd
mv Makefile Makefile.tmp
rm openocd_output
#Generate Makefile
./tm4c_genMakefile.sh
check
addDEBUGCFLSGS
diff
#如果有不同
if [ -n "$DIFF" ]; then
	make clean
	check
fi
make
check
echo -e "\033[33mLoading OPENOCD...\033[0m"
openocd --file ~/ToolChain/openocd/ek-tm4c123gxl.cfg >> openocd_output 2>&1 &
sleep 1s
ISERROR_OPENOCD=$(grep -a "Error" output_tmp)
if [ -n "$ISERROR_OPENOCD" ]; then
	echo -e "\033[31mYou haven't insert the devices!\033[0m"
	exit -1;
fi
getprjname
rm -rf gdbprecmd
sed "s/_PRJ_NAME_/${PRJNAME}/g" tm4c_gdbprecmdTemplate >> gdbprecmd
echo -e "\033[33mLoading GDB...\033[0m"
arm-none-eabi-gdb -x gdbprecmd -quiet gcc/${PRJNAME}.axf
killopenocd