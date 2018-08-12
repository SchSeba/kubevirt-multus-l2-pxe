go-build:
	go build l2-bridge.go

docker-build:
	docker build -t quay.io/schseba/l2-bridge-cni-plugin:latest .

docker-push: go-build docker-build
	docker push quay.io/schseba/l2-bridge-cni-plugin:latest
