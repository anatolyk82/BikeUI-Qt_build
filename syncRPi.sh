#!/bin/bash

trap "exit 0" 2

RMT_HOST="pi@192.168.1.102"
PASSWORD=""

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

#-----------

messageln "Creating sysroot"
mkdir sysroot

messageln "Creating sysroot/usr"
mkdir sysroot/usr

messageln "Creating sysroot/opt"
mkdir sysroot/opt

echo ""

askToContinue "Get files from the remote device ? (y/n) "
retValue=$?
if [ $retValue == 0 ]
then
	messageln "...directory /lib"
	sshpass -p $PASSWORD rsync -avz "$RMT_HOST:/lib" sysroot
	
	echo
	messageln "...directory /usr/include"
	sshpass -p $PASSWORD rsync -avz "$RMT_HOST:/usr/include" sysroot/usr

	echo
	messageln "...directory /usr/lib"
	sshpass -p $PASSWORD rsync -avz "$RMT_HOST:/usr/lib" sysroot/usr

	echo
	messageln "...directory /opt/vc"
	sshpass -p $PASSWORD rsync -avz "$RMT_HOST:/opt/vc" sysroot/opt

	echo
	messageln "...directory /usr/local/lib"
	sshpass -p $PASSWORD rsync -avz "$RMT_HOST:/usr/local/lib" sysroot/usr/local

	echo
	messageln "...directory /usr/local/include"
	sshpass -p $PASSWORD rsync -avz "$RMT_HOST:/usr/local/include" sysroot/usr/local

	echo
	messageln "Run sysroot-relativelinks.py..."
	./sysroot-relativelinks.py sysroot/
fi

echo ""

askToContinue "Send files to the remote device ? (y/n) "
retValue=$?
if [ $retValue == 0 ]
then
	echo
	messageln "Sending files to the remote device..."
	sshpass -p $PASSWORD rsync -avz qt5pi "$RMT_HOST:/usr/local/"
fi



