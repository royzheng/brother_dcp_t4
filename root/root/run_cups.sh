#!/bin/sh
set -eu

CUPSADMIN="${CUPSADMIN:-admin}"
CUPSPASSWORD="${CUPSPASSWORD:-$CUPSADMIN}"
TZ="${TZ:-Etc/UTC}"

configure_timezone() {
    if [ -f "/usr/share/zoneinfo/$TZ" ]; then
        ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
        printf '%s\n' "$TZ" > /etc/timezone
        return
    fi

    printf 'warning: timezone "%s" not found, falling back to Etc/UTC\n' "$TZ" >&2
    TZ="Etc/UTC"
    export TZ
    ln -snf /usr/share/zoneinfo/Etc/UTC /etc/localtime
    printf 'Etc/UTC\n' > /etc/timezone
}

configure_timezone

if ! id "$CUPSADMIN" >/dev/null 2>&1; then
    useradd -r -G lpadmin -M "$CUPSADMIN"
fi
printf '%s:%s\n' "$CUPSADMIN" "$CUPSPASSWORD" | chpasswd

install -d -m 755 /config /config/ppd /services /etc/avahi/services
rm -f /etc/avahi/services/*.service
rm -rf /etc/cups/ppd
ln -s /config/ppd /etc/cups/ppd

if find /services -maxdepth 1 -name '*.service' -print -quit | grep -q .; then
    cp -f /services/*.service /etc/avahi/services/
fi

if [ ! -f /config/printers.conf ]; then
    touch /config/printers.conf
fi
cp /config/printers.conf /etc/cups/printers.conf

if [ -f /config/cupsd.conf ]; then
    cp /config/cupsd.conf /etc/cups/cupsd.conf
else
    cp /etc/cups/cupsd.conf /config/cupsd.conf
fi

/usr/sbin/avahi-daemon --daemonize
/root/printer-update.sh &
exec /usr/sbin/cupsd -f
