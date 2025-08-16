help: ## Show this help.
	@ sed -nEe '/@sed/!s/[^:#]*##\s*/ /p' $(MAKEFILE_LIST) | column -tl 2

lint: ## Run standard linters.
	@ golangci-lint run ./...

test: ## Run unit tests.
	@ go test -coverpkg ./... -race ./...

build: ## Build the application.
	@ mkdir -p bin
	@ VERSION=$$(git describe --tag --always --dirty) && \
		go build -o bin/multirogue -ldflags "-X main.version=$$VERSION" \
		cmd/main.go

docker-run: ## Run the application in a local Docker container.
	@ docker build -t multirogue .
	@ docker run --rm -p 8080:8080 multirogue
