# royzheng/t426w:avahi

# Working on Synology DSM 7 and AMD64

Forked from [quadportnick/docker-cups-airprint](https://github.com/quadportnick/docker-cups-airprint).

This Ubuntu-based image runs CUPS plus Avahi so a Brother DCP-T426W can be exposed as an AirPrint printer on the local network.

## Highlights

* `Support Brother DCP-T426W`
* `Image/tag: royzheng/t426w:avahi`
* `Platform: linux/amd64`
* `Timezone via TZ, for example Asia/Shanghai`

## Quick start

```bash
sudo docker run -d --name t426w-airprint \
     --restart unless-stopped \
     --platform linux/amd64 \
     --net host \
     -v /volume1/docker/t426w/services:/services \
     -v /volume1/docker/t426w/config:/config \
     -e CUPSADMIN="admin" \
     -e CUPSPASSWORD="admin" \
     -e TZ="Asia/Shanghai" \
     royzheng/t426w:avahi
```

## Synology DSM 7 notes

Before starting the container on DSM 7, stop Synology's own print services if they are running:

* `sudo synosystemctl stop cupsd`
* `sudo synosystemctl stop cups-lpd`
* `sudo synosystemctl stop cups-service-handler`
* `sudo synosystemctl disable cupsd`
* `sudo synosystemctl disable cups-lpd`
* `sudo synosystemctl disable cups-service-handler`

After AirPrint is configured and verified, you can enable the Synology services again if needed:

* `sudo synosystemctl start cupsd`
* `sudo synosystemctl start cups-lpd`
* `sudo synosystemctl start cups-service-handler`
* `sudo synosystemctl enable cupsd`
* `sudo synosystemctl enable cups-lpd`
* `sudo synosystemctl enable cups-service-handler`

## Configure the printer

* Open CUPS at `http://<host-ip>:631`
* Log in with `CUPSADMIN` and `CUPSPASSWORD`
* Make sure to check `Share This Printer`
* After saving printer settings, close the browser for at least 60 seconds so CUPS flushes the config files

### Brother DCP-T426W setup example

* **Setup1**
![Setup1](https://raw.githubusercontent.com/royzheng/brother_dcp_t4/main/images/setup1.jpg "setup1")
* **Setup2**
![Setup2](https://raw.githubusercontent.com/royzheng/brother_dcp_t4/main/images/setup2.jpg "setup2")
* **Setup3**
![Setup3](https://raw.githubusercontent.com/royzheng/brother_dcp_t4/main/images/setup3.jpg "setup3")
* **Setup4**
![Setup4](https://raw.githubusercontent.com/royzheng/brother_dcp_t4/main/images/setup4.jpg "setup4")
* **Setup5**
![Setup5](https://raw.githubusercontent.com/royzheng/brother_dcp_t4/main/images/setup5.jpg "setup5")
* **Setup6**
![Setup6](https://raw.githubusercontent.com/royzheng/brother_dcp_t4/main/images/setup6.jpg "setup6")

## Volumes

* `/config`: persistent CUPS configuration
* `/services`: generated Avahi service files

## Environment variables

* `CUPSADMIN`: CUPS admin user, default `admin`
* `CUPSPASSWORD`: CUPS admin password, default follows `CUPSADMIN`
* `TZ`: timezone name, for example `Asia/Shanghai`; invalid values fall back to `Etc/UTC`

## Networking

Must run with host networking because AirPrint discovery relies on multicast.

## Compose

```bash
docker compose up -d --build
```

The included `docker-compose.yml` is already pinned to `royzheng/t426w:avahi`, `linux/amd64`, host networking, and `TZ=Asia/Shanghai`.

## Make helpers

```bash
make build
make start
make bash
```

`make start` uses host networking, mounts local `./config` and `./services`, and runs the image as `linux/amd64`.
