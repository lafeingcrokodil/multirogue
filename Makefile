.PHONY: $(shell ls)

help: ## Show this help.
	@ sed -nEe '/@sed/!s/[^:#]*##\s*/ /p' $(MAKEFILE_LIST) | column -tl 2

build: ## Build the application.
	@ mkdir -p bin
	@ VERSION=$$(git describe --tag --always --dirty) && \
		go build -o bin/multirogue -ldflags "-X main.version=$$VERSION" \
		cmd/web/main.go

lint: ## Run standard linters and a few additional explicitly enabled ones.
	@ golangci-lint run

lint-all: ## Run all linters that aren't explicitly disabled.
	@ golangci-lint run -c .golangci.all.yml

tsc: ## Compile TypeScript code.
	@ . $(HOME)/.nvm/nvm.sh \
		&& nvm install stable \
		&& npm install \
		&& npx tsc

test: ## Run unit tests.
	@ go test -coverpkg ./... -race ./...

web-docker: tsc ## Run the application in a local Docker container.
	@ docker build -t multirogue .
	@ docker run --rm -p 8080:8080 multirogue

web-dev: tsc ## Run the application locally without using Docker.
	@ go run cmd/web/main.go
