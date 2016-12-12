#!/bin/bash
# usage burn_maxoucard <SOFT_AP_NAME> <SOFT_AP_PASS> <AUTOCONNECT_PASS>
CONFIG_FILE="./maxoucard_config.h"
SOURCE_FILE="./maxoucard_wifi.ino"
ARDUINO_PATH="/Applications/Arduino.app/Contents/Java"
ARDUINO_PACKAGES="/Users/olivier/Library/Arduino15/packages"
IDE_VERSION="10612"

BUILD_PATH=$(pwd)"/build"
BINARY_FILE=$BUILD_PATH/$SOURCE_FILE".bin"

if [[ $# < 3 || $# > 4 ]]
then
	echo "*** ERROR: invalid parameters"
	echo "Usage: ./burn_maxoucard <SOFT_AP_NAME> <SOFT_AP_PASS> <AUTOCONNECT_PASS> [--skipcompile]"
else

	# build header configuration file
	echo "*** generating header configuration file..."
	rm $CONFIG_FILE
	touch $CONFIG_FILE
	echo "#define SOFTAP_NAME \""$1"\"" >> $CONFIG_FILE
	echo "#define SOFTAP_PASS \""$2"\"" >> $CONFIG_FILE
	echo "#define AUTOCONNECT_PASS \""$3"\"" >> $CONFIG_FILE

	# compile code
	if [ $# == 3 ] || [ $4 != "--skipcompile" ] || [ ! -f $BINARY_FILE ]
	then
		echo "compiling code..."
		rm -rf $BUILD_PATH
		mkdir $BUILD_PATH
		$ARDUINO_PATH/arduino-builder -compile -logger=machine -hardware $ARDUINO_PATH/hardware \
			-hardware $ARDUINO_PACKAGES \
			-tools $ARDUINO_PATH/tools-builder \
			-tools $ARDUINO_PATH/hardware/tools/avr \
			-tools $ARDUINO_PACKAGES \
			-built-in-libraries $ARDUINO_PATH/libraries \
			-libraries /Users/olivier/Documents/Arduino/libraries \
			-fqbn=esp8266:esp8266:generic:CpuFrequency=80,FlashFreq=40,FlashMode=dio,UploadSpeed=115200,FlashSize=512K64,ResetMethod=ck,Debug=Disabled,DebugLevel=None____ \
			-ide-version=$IDE_VERSION \
			-build-path $BUILD_PATH \
			-warnings=none \
			-prefs=build.warn_data_percentage=75 \
			-prefs=runtime.tools.esptool.path=$ARDUINO_PACKAGES/esp8266/tools/esptool/0.4.9 \
			-prefs=runtime.tools.mkspiffs.path=$ARDUINO_PACKAGES/esp8266/tools/mkspiffs/0.1.2 \
			-prefs=runtime.tools.xtensa-lx106-elf-gcc.path=$ARDUINO_PACKAGES/esp8266/tools/xtensa-lx106-elf-gcc/1.20.0-26-gb404fb9-2 \
			$SOURCE_FILE
	else
		echo "*** skipping compilation..."
	fi

	# list USB serial devices
	echo "*** listing USB serial devices..."
	USBSERIAL=$(ls /dev/cu.usbserial-*)
	
	if [[ ! -z $USBSERIAL ]]
	then
		echo "*** found device: "$USBSERIAL
		
		# upload compiled code
		echo "*** uploading firmware..."
		# ./esptool -vv -cd ck -cb 115200 -cp /dev/cu.usbserial-A50285BI -ca 0x00000 -cf /var/folders/3j/nvvh487j62x8xx1qvn9dbttr0000gn/T/arduino_build_299817/test_redirection2.ino.bin 
		$ARDUINO_PACKAGES/esp8266/tools/esptool/0.4.9/esptool -vv -cd ck -cb 115200 -cp $USBSERIAL -ca 0x00000 \
		-cf $BINARY_FILE

		echo "*** done !"
	else
		echo "*** ERROR: cannot find serial device. Is your programmer plugged in ?"
   	fi
fi