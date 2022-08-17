REGISTRY?=127.0.0.1/openshift-logging
FLUENTD_VERSION=$$(grep BUILD_VERSION fluentd/Dockerfile.in| cut -d "=" -f2)
FLUENTD_IMAGE?=$(REGISTRY)/logging-fluentd:$(FLUENTD_VERSION)
CONTAINER_ENGINE?=podman
CONTAINER_BUILDER?=podman
BUILD_ARGS?=build

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

update-vendor:
	FLUENTD_VERSION=$(FLUENTD_VERSION) ./hack/update-fluentd-vendor-gems.sh
.PHONY: update-vendor

install-gems:
	FLUENTD_VERSION=$(FLUENTD_VERSION); \
	for d in $$(ls fluentd/lib); do pushd fluentd/lib/$$d; rm *.gem; gem build *.gemspec; gem install -N *.gem; popd; done && \
	gem install bundler:$$(grep -r -C 1 'BUNDLED WITH' fluentd/Gemfile.lock | grep -o '[0-9\.]*') && \
	pushd fluentd && bundler install && popd
.PHONY: install-gems