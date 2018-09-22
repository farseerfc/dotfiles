#/bin/sh
rpi3="192.168.0.21"
allusb=$(usbip list -p -r $rpi3 | cut -d":" -f1 -s | sed 's|^[ \t]*||;/^$/d')
for busid in $allusb
do
	if [[ $busid = "1-1.1" ]]
	then
		# ignoring usb ethernet
		continue
	fi
	echo "Attaching $busid"
	usbip attach --remote=$rpi3 --busid=$busid
done
