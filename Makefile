export GO111MODULE=on
export GOFLAGS=-mod=vendor

lint:
	golangci-lint run ./...

test:
	go test -coverpkg ./... -race ./...

build:
	mkdir -p bin
	go build -o bin/multirogue cmd/main.go

docker-lint:
	docker pull golangci/golangci-lint:latest
	docker run -v `pwd`:/workspace -w /workspace -e GOFLAGS=-mod=vendor golangci/golangci-lint:latest \
		golangci-lint run ./...

docker-test:
	docker pull golang:1
	docker run -v `pwd`:/workspace -w /workspace -e GOFLAGS=-mod=vendor golang:1 \
		go test -coverpkg ./... -race ./...

docker-run:
	docker build -t multirogue .
	docker run --rm -p 8080:8080 multirogue
