REGISTRY=registry.giantswarm.io/seiffert
PROJECT_DIR=/opt/symfony
MAKEFILE_DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY=all build run-dev push

all: build

build:
	docker build -t $(REGISTRY)/symfony-nginx nginx
	docker build -t $(REGISTRY)/symfony-fpm php-fpm

stop-dev:
	docker stop nginx > /dev/null 2> /dev/null && \
		echo "Stopped Nginx container" || \
		echo "Nginx not running"
	docker stop fpm > /dev/null 2> /dev/null && \
		echo "Stopped PHP-FPM container" || \
		echo "PHP-FPM not running"
	
rm-dev:
	docker rm nginx > /dev/null 2> /dev/null && \
		echo "Removed Nginx container" || \
		echo "Nginx container not found"
	docker rm fpm > /dev/null 2> /dev/null && \
		echo "Removed PHP-FPM container" || \
		echo "PHP-FPM container not found"

run-dev: stop-dev rm-dev
	docker run -d --name fpm -v $(MAKEFILE_DIR)/php-fpm/symfony:$(PROJECT_DIR) $(REGISTRY)/symfony-fpm
	docker run -d --name nginx -v $(MAKEFILE_DIR)/php-fpm/symfony:$(PROJECT_DIR) --link fpm:fpm -p 8000:80 $(REGISTRY)/symfony-nginx

push: build
	docker push $(REGISTRY)/symfony-nginx
	docker push $(REGISTRY)/symfony-fpm