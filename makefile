VERSION=3.5.0-2

build:
	docker stop brother_dcp_t4 || true
	docker container prune -f
	docker build -t royzheng/brother_dcp_t4:latest --progress=plain  . 2>&1 | tee build.log

start:
	docker run -d -p 631:631 --name brother_dcp_t4 royzheng/brother_dcp_t4:latest

stop:
	docker stop brother_dcp_t4 || true
	docker container prune -f

restart:
	make stop
	make start

push:
	docker push royzheng/brother_dcp_t4:latest

bash:
	docker exec -it brother_dcp_t4 bash
