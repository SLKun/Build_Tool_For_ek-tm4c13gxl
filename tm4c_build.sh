###################################
#
# Auto Build and Flash for ek-tm4c123gxl
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
killopenocd(){
	OPENOCD_PID=$(ps -ef | grep -a openocd | awk '{print $2}')
	if [ -n "$OPENOCD_PID" ]; then
		kill -9 "$OPENOCD_PID"
	fi
}

killopenocd
mv Makefile Makefile.tmp
./tm4c_genMakefile.sh
check
diff
#如果有不同
if [ -n "$DIFF" ]; then
	make clean
	check
fi
make
check
USBDEVICES=$(LMFlash --usbdevices)
if [ -n "$USBDEVICES" ]; then
	getprjname
	LMFlash --quick-set=ek-tm4c123gxl --verify --reset gcc/${PRJNAME}.bin
	echo -e "\033[31m\033[0m"
	echo -e "\033[32mFinished!\033[0m"
else
	echo -e "\033[31mYou haven't insert the devices!\033[0m"
fi