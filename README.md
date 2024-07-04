# royzheng/brother_dcp_t4 [docker-image](https://hub.docker.com/r/royzheng/brother_dcp_t4)

# Working on Synology DSM 7 (!!!) and AMD64

Fork from [quadportnick/docker-cups-airprint](https://github.com/quadportnick/docker-cups-airprint)

This Ubuntu-based Docker image runs a CUPS instance that is meant as an AirPrint relay for printers that are already on the network but not AirPrint capable.
* `Included drivers HP, Samsung, Canon, Xerox, etc.`
* `Support Brother DCP-T420W, DCP-T425W, DCP-T426W, DCP-T428W`

## Easy run command (use username and password: admin/admin):
```
sudo docker run -d --name t426w \
     --restart unless-stopped  --net host\
     -v /volume1/docker/t426w/services:/services \
     -v /volume1/docker/t426w/config:/config \
     -e CUPSADMIN="admin" \
     -e CUPSPASSWORD="admin" \
     -e TZ="Asia/Shanghai" \
     royzheng/brother_dcp_t4:latest
```

### Before run docker conteiner on DSM7 Synology run this commands in ssh terminal(if your airplay service is running)):
* `sudo synosystemctl stop cupsd`
* `sudo synosystemctl stop cups-lpd`
* `sudo synosystemctl stop cups-service-handler`
* `sudo synosystemctl disable cupsd`
* `sudo synosystemctl disable cups-lpd`
* `sudo synosystemctl disable cups-service-handler`

### Add and setup printer:
* CUPS will be configurable at http://[host ip]:631 using the CUPSADMIN/CUPSPASSWORD.
* Make sure you select `Share This Printer` when configuring the printer in CUPS.
* ***After configuring your printer, you need to close the web browser for at least 60 seconds. CUPS will not write the config files until it detects the connection is closed for as long as a minute.***

### Brother DCP-T426W cups setup example(DCP-T420W, DCP-T425W, DCP-T428W also like this)
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

### After setup and testing AirPrint, you can back run on services. (maybe you will need restart nas)
* `sudo synosystemctl start cupsd`
* `sudo synosystemctl start cups-lpd`
* `sudo synosystemctl start cups-service-handler`
* `sudo synosystemctl anable cupsd`
* `sudo synosystemctl anable cups-lpd`
* `sudo synosystemctl anable cups-service-handler`

## Manual Configuration

### Volumes:
* `/config`: where the persistent printer configs will be stored
* `/services`: where the Avahi service files will be generated

### Variables:
* `CUPSADMIN`: the CUPS admin user you want created - default is `admin` if unspecified
* `CUPSPASSWORD`: the password for the CUPS admin user - default is `admin` username if unspecified
* `TZ`: time zone

### Ports/Network:
* Must be run on host network. This is required to support multicasting which is needed for Airprint.


### Example run env command:
```
docker run -d --name airprint \
     --restart unless-stopped  --net host\
     -v <your services dir>:/services \
     -v <your config dir>:/config \
     -e CUPSADMIN="admin" \
     -e CUPSPASSWORD="admin" \
     -e TZ="Asia/Shanghai" \
     royzheng/brother_dcp_t4:latest
```