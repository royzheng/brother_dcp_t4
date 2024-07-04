FROM ubuntu:jammy
LABEL maintainer="Roy Zheng"
LABEL version="3.5.0-2"
LABEL description="AIRPRINT FROM SYNOLOGY DSM 7 (HP, SAMSUNG, ETC)"

RUN apt-get update && apt-get install -y \
  vim \
	locales \
	brother-lpr-drivers-extra brother-cups-wrapper-extra \
	printer-driver-splix \
	printer-driver-gutenprint \
	gutenprint-doc \
	gutenprint-locales \
	libgutenprint9 \
	libgutenprint-doc \
	ghostscript \
	hplip \
	cups \
	cups-pdf \
	cups-client \
	cups-filters \
	inotify-tools \
	avahi-daemon \
	avahi-discover \
	python3 \
	python3-dev \
	python3-pip \
	python3-cups \
	wget \
	rsync \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /root/*

#Run Script
CMD ["/root/run_cups.sh"]

COPY deb/*.deb /tmp/

RUN dpkg -x /tmp/dcpt420wpdrv-3.5.0-1.i386.deb / \
    && dpkg -i --force-all /tmp/dcpt420wpdrv-3.5.0-1a.i386.deb \
    && dpkg -x /tmp/dcpt425wpdrv-3.5.0-1.i386.deb / \
    && dpkg -i --force-all /tmp/dcpt425wpdrv-3.5.0-1a.i386.deb \
    && dpkg -x /tmp/dcpt426wpdrv-3.5.0-2.i386.deb / \
    && dpkg -i --force-all /tmp/dcpt426wpdrv-3.5.0-2a.i386.deb \
    && dpkg -x /tmp/dcpt428wpdrv-3.5.0-1.i386.deb / \
    && dpkg -i --force-all /tmp/dcpt428wpdrv-3.5.0-1a.i386.deb \
    && dpkg -i --force-all /tmp/brscan5-1.3.3-0.amd64.deb \
    && dpkg -i --force-all /tmp/brscan-skey-0.3.2-0.amd64.deb \
    && rm -rf /tmp/*.deb
  
# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen *:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing No/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
	echo "BrowseWebIF Yes" >> /etc/cups/cupsd.conf

ENV CUPSADMIN="admin" \
    CUPSPASSWORD="admin" \
    TZ="Asia/Shanghai"
