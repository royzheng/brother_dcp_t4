#!/bin/sh
set -eu

sync_printers() {
	rm -f /services/AirPrint-*.service /etc/avahi/services/AirPrint-*.service
	/root/airprint-generate.py -d /services
	cp /etc/cups/printers.conf /config/printers.conf
	rsync -a --delete /services/ /etc/avahi/services/
	install -d -m 755 /var/cache/cups
	rm -rf /var/cache/cups/*
}

sync_cupsd_conf() {
	cp /etc/cups/cupsd.conf /config/cupsd.conf
}

wait_for_cups() {
	attempt=0
	while [ "$attempt" -lt 30 ]; do
		if lpstat -r >/dev/null 2>&1; then
			return 0
		fi
		attempt=$((attempt + 1))
		sleep 1
	done

	return 1
}

initial_sync() {
	if ! wait_for_cups; then
		printf 'warning: CUPS did not become ready in time, skipping initial AirPrint sync\n' >&2
		return
	fi

	sync_printers
	sync_cupsd_conf
}

initial_sync &

/usr/bin/inotifywait -m -e close_write,moved_to,create /etc/cups |
while read -r directory events filename; do
	case "$filename" in
		printers.conf)
			sync_printers
			;;
		cupsd.conf)
			sync_cupsd_conf
			;;
	esac
done
