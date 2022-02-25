REGISTRY?=127.0.0.1/openshift-logging
FLUENTD_VERSION=$$(grep BUILD_VERSION fluentd/Dockerfile.in| cut -d "=" -f2)
FLUENTD_IMAGE?=$(REGISTRY)/logging-fluentd:$(FLUENTD_VERSION)
CONTAINER_ENGINE?=docker
CONTAINER_BUILDER?=imagebuilder
BUILD_ARGS?=

image:
	$(CONTAINER_BUILDER) $(BUILD_ARGS) --build-arg FLUENTD_VERSION_VALUE=$(FLUENTD_VERSION) -f fluentd/Dockerfile -t $(FLUENTD_IMAGE) fluentd
.PHONY: image

lint:
	@hack/run-linter
.PHONY: lint

gen-dockerfiles:
	@for d in "fluentd" ; do  \
		./hack/generate-dockerfile-from-midstream "$$d/Dockerfile.in" > "$$d/Dockerfile" ; \
	done
.PHONY: gen-dockerfiles

test-unit:
	$(CONTAINER_BUILDER) -t logging-fluentd-unit-tests -f Dockerfile.unit .
	# podman run logging-fluentd-unit-tests
.PHONY: test-unit
