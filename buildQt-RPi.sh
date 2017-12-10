#!/bin/bash


WORK_DIR="/home/anatoly/raspi"


RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color
message() {
   echo -n -e ${GREEN}$1${NC}
}
messageln() {
   echo -e ${GREEN}$1${NC}
}
errormsg() {
   echo -e ${RED}$1${NC}
}
askToContinue() {
   # askToContinue "question"
   while true
   do
     message "$1"
     read -n 1 q
     if [ "$q" == "y" ]
     then
       echo
       return 0
     else if [ "$q" == "n" ]
       then
         echo
         return 1
       fi
     fi
     echo
   done
}

checkDirectory() {
	echo -n "Checking directory $1 ... "
	if [ ! -d "$1" ]
	then
		echo "failure"
		echo "$2"
		exit 1
		fi
	echo "ok"
}

printAndPause() {
	echo
    echo -n "$1"
	i=0
	while true
	do
		if [ "$i" -eq 5 ]
		then
			break
		else
			echo -n "."
			i=`expr $i + 1`
			sleep 1
		fi
	done
    echo
}




cd $WORK_DIR

checkDirectory "./sysroot" "There should be a directory called sysroot here"


if [ ! -d "tools" ]
then
	askToContinue "RPi tools will be cloned (y/n)"
	retValue=$?
	if [ $retValue == 0 ]
	then
		git clone https://github.com/raspberrypi/tools
	fi
fi
checkDirectory "./tools" "Run: git clone https://github.com/raspberrypi/tools"


if [ ! -d "qt5" ]
then
	askToContinue "Qt5 repository will be cloned (y/n) "
	retValue=$?
	if [ $retValue == 0 ]
	then
		git clone git://code.qt.io/qt/qt5.git
	else
		echo "You must have a Qt source repository to continue"
		exit 10
	fi
fi
checkDirectory "./qt5" "Run: git clone git://code.qt.io/qt/qt5.git"



cd ./qt5


askToContinue "'./init-repository' will be run (y/n) "
retValue=$?
if [ $retValue == 0 ]
then
	./init-repository
	echo
	fi


askToContinue "make distclean? (y/n) "
retValue=$?
if [ $retValue == 0 ]
	then
	make distclean
	echo
fi

askToContinue "Clean configure? (y/n) "
retValue=$?
if [ $retValue == 0 ]
	then
		git clean -dfx
		echo
fi


askToContinue "Run ./configure ? (y/n) "
retValue=$?
if [ $retValue == 0 ]
then
	./configure -release -opengl es2 -device linux-rasp-pi-g++ -device-option CROSS_COMPILE=$WORK_DIR/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf- \
		-sysroot $WORK_DIR/sysroot -opensource -confirm-license -make libs -prefix /usr/local/qt5pi -extprefix $WORK_DIR/qt5pi -hostprefix $WORK_DIR/qt5 -v \
		-skip qtandroidextras -skip qtcanvas3d -skip qtdatavis3d -skip qtenginio -skip qtdoc -skip qtfeedback -skip qtdocgallery \
		-skip qtdocgallery -skip qtpim -skip qt3d -skip qtmacextras -skip qtwinextras -skip qtwebsockets -skip qtwebchannel -skip qtwebengine -skip qtwebview -skip qtpurchasing \
		-skip qtgamepad -skip qtspeech -skip qtnetworkauth -no-use-gold-linker
	
#	./configure -release -opengl es2 -device linux-rasp-pi3-g++ -device-option CROSS_COMPILE=$WORK_DIR/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf- \
#		-sysroot $WORK_DIR/sysroot -opensource -confirm-license -make libs -prefix /usr/local/qt5pi -extprefix $WORK_DIR/qt5pi -hostprefix $WORK_DIR/qt5 -v \
#		-skip qtandroidextras -skip qtcanvas3d -skip qtdatavis3d -skip qtenginio -skip qtdoc -skip qtfeedback -skip qtdocgallery \
#		-skip qtdocgallery -skip qtpim -skip qt3d -skip qtmacextras -skip qtwinextras -skip qtwebsockets -skip qtwebchannel -skip qtwebengine -skip qtwebview -skip qtpurchasing \
#		-skip qtgamepad -skip qtspeech -skip qtnetworkauth -no-use-gold-linker
	echo
fi


askToContinue "make? (y/n) "
retValue=$?
if [ $retValue == 0 ]
then
	make -j8
	echo
fi


askToContinue "make install? (y/n) "
retValue=$?
if [ $retValue == 0 ]
then
	make install
	echo
fi




