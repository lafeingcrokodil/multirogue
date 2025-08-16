.PHONY: $(shell ls)

help: ## Show this help.
	@ sed -nEe '/@sed/!s/[^:#]*##\s*/ /p' $(MAKEFILE_LIST) | column -tl 2

build: ## Build the application.
	@ mkdir -p bin
	@ VERSION=$$(git describe --tag --always --dirty) && \
		go build -o bin/multirogue -ldflags "-X main.version=$$VERSION" \
		cmd/main.go

lint: ## Run standard linters and a few additional explicitly enabled ones.
	@ golangci-lint run

lint-all: ## Run all linters that aren't explicitly disabled.
	@ golangci-lint run -c .golangci.all.yml

test: ## Run unit tests.
	@ go test -coverpkg ./... -race ./...

docker-run: ## Run the application in a local Docker container.
	@ docker build -t multirogue .
	@ docker run --rm -p 8080:8080 multirogue
