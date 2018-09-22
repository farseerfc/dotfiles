#/bin/sh
(
allusb=$(usbip list -p -l)
for usb in $allusb
do
	busid=$(echo $usb | sed "s|#.*||g;s|busid=||g")
	if [[ $busid = "1-1.1" ]]
	then
		# ignoring usb ethernet
		continue
	fi
	echo "$(date -Iseconds): Exporting $busid"
	usbip bind --busid=$busid
done
) >>/var/log/usbipall.log 2>&1 
