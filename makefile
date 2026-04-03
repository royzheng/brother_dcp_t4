VERSION := 3.5.0-2
IMAGE := royzheng/t426w:latest
PLATFORM := linux/amd64
CONTAINER := t426w-airprint
CONFIG_DIR := $(CURDIR)/config
SERVICES_DIR := $(CURDIR)/services
CUPSADMIN ?= admin
CUPSPASSWORD ?= admin
TZ ?= Asia/Shanghai

.PHONY: build start stop restart push bash

build:
	mkdir -p "$(CONFIG_DIR)" "$(SERVICES_DIR)"
	docker rm -f $(CONTAINER) >/dev/null 2>&1 || true
	docker build --platform $(PLATFORM) -t $(IMAGE) --progress=plain . 2>&1 | tee build.log

start:
	mkdir -p "$(CONFIG_DIR)" "$(SERVICES_DIR)"
	docker rm -f $(CONTAINER) >/dev/null 2>&1 || true
	docker run -d \
		--name $(CONTAINER) \
		--restart unless-stopped \
		--net host \
		--platform $(PLATFORM) \
		-v "$(SERVICES_DIR):/services" \
		-v "$(CONFIG_DIR):/config" \
		-e CUPSADMIN="$(CUPSADMIN)" \
		-e CUPSPASSWORD="$(CUPSPASSWORD)" \
		-e TZ="$(TZ)" \
		$(IMAGE)

stop:
	docker rm -f $(CONTAINER) >/dev/null 2>&1 || true

restart:
	$(MAKE) stop
	$(MAKE) start

push:
	docker push $(IMAGE)

bash:
	docker exec -it $(CONTAINER) bash
