BINARY_NAME=proxbox
PKG=github.com/footgunz/proxbox
DIST_DIR=dist
VERSION ?= $(shell cat VERSION)
COMMIT_SHA ?= $(shell git rev-parse --short HEAD)

OS := $(shell uname -s)

.PHONY: all clean docker-build

# Default target only builds binaries
all: linux-amd64 linux-arm64 darwin-amd64 darwin-arm64

clean:
	rm -rf $(DIST_DIR)

LDFLAGS += -X $(PKG)/cmd.Version=${VERSION} -X $(PKG)/cmd.CommitSHA=${COMMIT_SHA}

linux-amd64:
	mkdir -p $(DIST_DIR)/linux-amd64
	GOOS=linux GOARCH=amd64 go build -ldflags="$(LDFLAGS) -s -w" -o $(DIST_DIR)/linux-amd64/$(BINARY_NAME)

linux-arm64:
	mkdir -p $(DIST_DIR)/linux-arm64
	GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o $(DIST_DIR)/linux-arm64/$(BINARY_NAME)

darwin-amd64:
	mkdir -p $(DIST_DIR)/darwin-amd64
	GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w" -o $(DIST_DIR)/darwin-amd64/$(BINARY_NAME)

darwin-arm64:
	mkdir -p $(DIST_DIR)/darwin-arm64
	GOOS=darwin GOARCH=arm64 go build -ldflags="-s -w" -o $(DIST_DIR)/darwin-arm64/$(BINARY_NAME)

# Docker build must be explicitly called
docker-build:
	docker buildx create --use --name multiarch --node multiarch
ifeq ($(OS),Darwin)
	docker buildx build --platform linux/$(shell uname -m | sed 's/x86_64/amd64/;s/arm64/arm64/') \
		-t $(BINARY_NAME):$(VERSION) \
		-t $(BINARY_NAME):latest \
		--load .
else
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t $(BINARY_NAME):$(VERSION) \
		-t $(BINARY_NAME):latest \
		--load .
endif
