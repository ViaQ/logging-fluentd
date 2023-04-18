REGISTRY?=127.0.0.1:5000/openshift-logging
FLUENTD_VERSION=$(shell grep BUILD_VERSION fluentd/Dockerfile| cut -d "=" -f2)
FLUENTD_IMAGE?=$(REGISTRY)/logging-fluentd:$(FLUENTD_VERSION)
CONTAINER_ENGINE?=podman
CONTAINER_BUILDER?=podman
BUILD_ARGS?=build

image:
	$(CONTAINER_BUILDER) $(BUILD_ARGS) --build-arg FLUENTD_VERSION_VALUE=$(FLUENTD_VERSION) -f fluentd/Dockerfile -t $(FLUENTD_IMAGE) fluentd
.PHONY: image

lint:
	@exit 0
.PHONY: lint

test-unit:
	$(CONTAINER_BUILDER) $(BUILD_ARGS) -t logging-fluentd-unit-tests -f Dockerfile.unit .
	# podman run logging-fluentd-unit-tests
.PHONY: test-unit

install-gems: 
	FLUENTD_VERSION=$(FLUENTD_VERSION) ; \
	for d in $$(ls fluentd/lib); do pushd fluentd/lib/$$d; rm *.gem; gem build *.gemspec; gem install -N *.gem; popd; done && \
	gem install bundler:$$(grep -r -C 1 'BUNDLED WITH' fluentd/Gemfile.lock | grep -o '[0-9\.]*') && \
	pushd fluentd && bundler install && popd
.PHONY: install-gems

update-libs-for-fluentd:
	FLUENTD_VERSION=$(FLUENTD_VERSION) ; \
	for d in $$(ls fluentd/lib); do pushd fluentd/lib/$$d ; \
		grep fluentd $$(ls *.gemspec) ; \
		if [ "$$?" -eq "0" ] ; then  \
		sed -i "s/add.*dependency.*\"fluentd\".*/add_runtime_dependency \"fluentd\", \"=$$FLUENTD_VERSION\"/" $$(ls *.gemspec) ; \
		bundle update fluentd --conservative --bundler ; \
		fi ; \
		popd ; \
	done
.PHONY: update-libs-for-fluentd
