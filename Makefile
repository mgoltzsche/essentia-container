IMAGE ?= ghcr.io/mgoltzsche/essentia
VERSION ?= dev
PLATFORMS ?= linux/arm64/v8,linux/amd64

BUILDER := essentia-builder
BUILD_OPTS :=

all: build

.PHONY: build
build:
	docker build --force-rm -t $(IMAGE):$(VERSION) .

build-release: create-builder
	docker buildx build --builder=$(BUILDER) --platform=$(PLATFORMS) $(BUILD_OPTS) --force-rm -t $(IMAGE):$(VERSION) -t $(IMAGE):latest .

create-builder:
	docker buildx inspect --name=$(BUILDER) >/dev/null 2<&1 || docker buildx create --name=$(BUILDER) >/dev/null

delete-builder:
	docker buildx rm --name=$(BUILDER)

release: BUILD_OPTS=--push
release: build-release

enable-qemu:
	docker run --rm --privileged multiarch/qemu-user-static:7.2.0-1 --reset -p yes

