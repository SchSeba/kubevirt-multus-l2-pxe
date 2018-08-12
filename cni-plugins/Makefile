all: docker-build docker-push

docker-build:
	docker build -t quay.io/schseba/cni-plugins:latest .

docker-push:
	docker push quay.io/schseba/cni-plugins:latest
