#!/bin/sh

if [ "$1" = "load" ];then
	if lsmod | grep -q a64servo ; then
		echo "Module already loaded! Exiting..."
		exit 0
	else
		modprobe a64servo.ko
		echo "Module loaded"
	fi
		
	if ls /dev | grep -q servo ; then
		echo "Node existed! Exiting..."
		exit 0
	else
		mknod /dev/servo c 215 0
		echo "Node created"
	fi
elif [ "$1" = "unload" ];then
	if lsmod | grep -q a64servo ; then
		rmmod a64servo.ko
		echo "Module unloaded"
	fi

	if ls /dev | grep -q servo ; then
		rm /dev/servo
		echo "Node deleted"
	fi
else
	echo "usage: servo (un)load"
fi
