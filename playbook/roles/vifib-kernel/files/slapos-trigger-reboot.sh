#!/bin/bash

FILE=/opt/upgrader/REBOOT_REQUIRED
if [[ -f "$FILE" ]]; 
then
	rm $FILE
	/sbin/reboot
fi
