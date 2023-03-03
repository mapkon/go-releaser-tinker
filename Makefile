NAME=go-releaser-tinker
ARCH=$(shell uname -m)
OS=$(shell uname)
VERSION=1.0.0
ITERATION := 1

GOLANGCI_VERSION = 1.51.2
GORELEASER_VERSION = 1.15.2

SOURCE_FILES?=$$(go list ./... | grep -v /vendor/)
TEST_PATTERN?=.
TEST_OPTIONS?=

BIN_DIR := $(CURDIR)

ci: prepare test

mod:
	@go mod download
	@go mod tidy
.PHONY: mod

lint: 
	@echo "--- lint all the things"
	@docker run --rm -v $(shell pwd):/app -w /app golangci/golangci-lint:v$(GOLANGCI_VERSION) golangci-lint run -v
.PHONY: lint

lint-fix:
	@echo "--- lint all the things"
	@docker run --rm -v $(shell pwd):/app -w /app golangci/golangci-lint:v$(GOLANGCI_VERSION) golangci-lint run -v --fix
.PHONY: lint-fix

fmt: lint-fix

run:
	go run ./src
install:
	go install ./src/main
.PHONY: mod

build:
ifeq ($(OS),Darwin)
	goreleaser build --snapshot --rm-dist --config $(CURDIR)/.goreleaser.macos-latest.yml
else ifeq ($(OS),Linux)
	goreleaser build --snapshot --rm-dist --config $(CURDIR)/.goreleaser.ubuntu-latest.yml
else
	$(error Unsupported build OS: $(OS))
endif
.PHONY: build

clean:
	@rm -fr ./build
.PHONY: clean

test:
	@echo "--- test all the things"
	@go test -cover ./...
.PHONY: test
