
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
	@for d in $$(ls ./fluentd/lib) ; do \
		echo Running tests for $$d ; \
		pushd fluentd/lib/$${d} ; \
			GEM_HOME=./vendor bundle install ; \
			out=$(GEM_HOME=./.vendor bundle exec rake test) ; \
			result=$$?
			echo $$out
			if [ "$$result" != "0" ] ; then \
				failed=1 ; \
			fi ; \
		popd ; \
	done ; \
	exit ${failed:-0}
.PHONY: test-unit
