#!/bin/bash

: "${WD_REBOOT_WAIT:=60}"

iface=${1:?no interface} || exit 1
state=present
quit=0

YELL() {
	logger -s -t ipwatchdog -p daemon.emerg "$*"
}

LOG() {
	echo "${0##*/}: $*" >&2
}

if ! ip link show "$iface" >/dev/null 2>&1; then
	echo "ERROR: $iface: no such interface" >&2
	exit 1
fi

trap 'quit=1' INT TERM
LOG "start monitoring interface $iface"
while ((!quit)); do
	addr=$(ip -o addr show "$iface" | awk '$3 == "inet" {print $4}')

	if [[ "$state" = present ]]; then
		if [[ -z "$addr" ]]; then
			YELL "interface $iface has no address; will reboot in $WD_REBOOT_WAIT seconds"
			state=missing
			systemctl restart ipwatchdog-reboot.timer
		fi
	else
		if [[ -n "$addr" ]]; then
			YELL "interface $iface has recovered; address is $addr"
			state=present
			systemctl stop ipwatchdog-reboot.timer
		fi
	fi

	sleep 10
done
LOG "stop monitoring interface $iface"
