
FLUENTD_IMAGE?="openshift/origin-logging-fluentd"

image:
	hack/build-component-image.sh "fluentd" $(FLUENTD_IMAGE)
.PHONY: image

deploy: image
	hack/deploy-component-image.sh $(FLUENTD_IMAGE)
.PHONY: deploy

lint:
	@hack/run-linter
.PHONY: lint

gen-dockerfiles:
	@for d in "fluentd" ; do  \
		./hack/generate-dockerfile-from-midstream "$$d/Dockerfile.in" > "$$d/Dockerfile" ; \
	done
.PHONY: gen-dockerfiles

test-unit:
	@export FLUENTD_VERSION=1.7.4; export GEM_HOME=$$(pwd)/.vendor; \
	gem install rake bundler -N ; \
	for d in $$(ls ./fluentd/lib) ; do \
		pushd fluentd/lib/$${d} ; \
			$$(bundle install) ; \
			out=$$(bundle exec rake test) ; \
			if [ "$$?" != "0" ] ; then exit 1 ; fi ; \
			echo "\n$$out" ; \
			echo  ; \
		popd ; \
	done
.PHONY: test-unit
