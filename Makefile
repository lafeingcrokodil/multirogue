lint:
	golangci-lint run ./...

test:
	go test -coverpkg ./... -race ./...

build:
	mkdir -p bin
	VERSION=$$(git describe --tag --always --dirty) && \
		go build -o bin/multirogue -ldflags "-X main.version=$$VERSION" \
		cmd/main.go

docker-run:
	docker build -t multirogue .
	docker run --rm -p 8080:8080 multirogue
