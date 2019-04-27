RUBBERNECKER_DIR=$(shell pwd)

DOCKER = $(shell command -v docker)

GO     := $(if $(shell which go),go,docker run --rm -v $(RUBBERNECKER_DIR):$(RUBBERNECKER_DIR) -w $(RUBBERNECKER_DIR) golang:1.9 go)
DEP    := $(if $(shell which dep),dep,$(GO) get -u github.com/golang/dep/cmd/dep && dep)
GOLINT := $(if $(shell which golint),golint,$(GO) get -u github.com/golang/lint/golint && golint)
NPM    := $(if $(shell which npm),npm,docker run --rm -v $(RUBBERNECKER_DIR):$(RUBBERNECKER_DIR) -w $(RUBBERNECKER_DIR) node:carbon-alpine npm)

build: styles compile

check_evn:
	$(if $(DOCKER),,$(error "docker not found in PATH"))

compile:
	$(GO) build -o bin/rubbernecker

dependencies:
	$(DEP) ensure -vendor-only
	$(NPM) install

lint:
	$(GO) fmt ./...
	$(GO) vet ./...
	$(GOLINT) . pkg/...
	$(NPM) run tslint

styles:
	$(NPM) run sass

watch:
	$(NPM) run sass:watch

test:
	$(GO) test -v ./...
