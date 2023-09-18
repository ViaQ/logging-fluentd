FROM registry.access.redhat.com/ubi9/ruby-31 AS builder

ENV REMOTE_SOURCES=${REMOTE_SOURCES:-"."}
ENV REMOTE_SOURCES_DIR=${REMOTE_SOURCES_DIR:-"."}

USER 0
RUN : 'removed yum-config-manager' \
 &&   BUILD_PKGS="make gcc-c++ libffi-devel autoconf automake libtool m4 redhat-rpm-config libxml2-devel" \
 &&   RUNTIME_PKGS="hostname bc iproute" \
 &&   dnf install -y --setopt=tsflags=nodocs $BUILD_PKGS $RUNTIME_PKGS \
 &&   rpm -V $BUILD_PKGS \
 &&   rpm -V $RUNTIME_PKGS \
 &&   dnf clean all


ENV upstream_code=${upstream_code:-"."} \
    HOME=/opt/app-root/src 

COPY ${upstream_code}/lib  ${HOME}/lib
COPY ${upstream_code}/Gemfile* ${HOME}/
WORKDIR ${HOME}

RUN CONFIGURE_ARGS="--with-cflags='$( rpm --eval %optflags )'" bundle install && \
    for d in $(ls lib); do pushd lib/$d; gem build --force -V *.gemspec; \ 
    gem install -N -minimal-deps --local --force --install-dir /usr/share/gems --bindir /usr/bin *.gem; popd; done

# Patch gems from upstream which are no longer vendored
COPY ${upstream_code}/*.patch /usr/share/gems
RUN  mv /usr/share/gems/aws-sdk-core.source0001.patch /usr/share/gems/gems/aws-sdk-core-*/ && \
     cd /usr/share/gems/gems/aws-sdk-core-*/ && patch -p1 < aws-sdk-core.source0001.patch && \
     cd /usr/share/gems &&  \
     mv /usr/share/gems/fluent-plugin-detect-exceptions.source0001.patch /usr/share/gems/gems/fluent-plugin-detect-exceptions-*/ && \
     cd /usr/share/gems/gems/fluent-plugin-detect-exceptions-*/ && patch -p1 < fluent-plugin-detect-exceptions.source0001.patch && \
     mv /usr/share/gems/fluent-plugin-elasticsearch.source0001.patch /usr/share/gems/gems/fluent-plugin-elasticsearch-*/ && \
     cd /usr/share/gems/gems/fluent-plugin-elasticsearch-*/ && patch -p1 < fluent-plugin-elasticsearch.source0001.patch && \
     mv /usr/share/gems/log4366_ruby_lib_net_http.patch /usr/share/ruby/ && \
     cd /usr/share/ruby && patch -p1 < log4366_ruby_lib_net_http.patch

FROM registry.access.redhat.com/ubi9/ubi-minimal AS runtime

ENV REMOTE_SOURCES=${REMOTE_SOURCES:-"."}
ENV upstream_code=${upstream_code:-"."}

ENV BUILD_VERSION=1.16.2
ENV OS_GIT_MAJOR=1
ENV OS_GIT_MINOR=16
ENV OS_GIT_PATCH=2

ARG DATA_VERSION_VALUE=1.6.0
ARG FLUENTD_VERSION_VALUE=1.16.2
ARG CONTAINER_VALUE=oci

ENV DATA_VERSION=$DATA_VERSION_VALUE \
    FLUENTD_VERSION=$FLUENTD_VERSION_VALUE \
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH \
    container=$CONTAINER_VALUE \
    RUBY_MAJOR_VERSION=3 \
    RUBY_MINOR_VERSION=1

USER 0
RUN RUNTIME_PKGS="hostname bc iproute libxml2 ruby" \
 &&   microdnf -y module enable ruby:${RUBY_MAJOR_VERSION}.${RUBY_MINOR_VERSION} \
 &&   microdnf install -y --setopt=tsflags=nodocs $RUNTIME_PKGS \
 &&   rpm -V $RUNTIME_PKGS \
 &&   microdnf clean all --enablerepo='*'

RUN mkdir -p /etc/fluent/plugin

COPY --from=builder /usr/bin/fluentd /usr/local/bin
COPY --from=builder /usr/bin/fluent-cat /usr/local/bin

COPY --from=builder /usr/share/gems /usr/share/gems
COPY --from=builder /usr/lib64/gems/ruby /usr/lib64/gems/ruby
COPY --from=builder /usr/share/ruby/net/http.rb /usr/share/ruby/net/
COPY ${upstream_code}/run.sh ${HOME}/
COPY ${upstream_code}/utils/ /usr/local/bin/

RUN mkdir -p /etc/fluent/configs.d/user && \
    chmod 777 /etc/fluent/configs.d/user && \
    ln -s /etc/fluent/configs.d/user/fluent.conf /etc/fluent/fluent.conf

WORKDIR ${HOME}
CMD ["sh", "run.sh"]

LABEL \
        io.k8s.description="Fluentd container for collecting of container logs" \
        io.k8s.display-name="Fluentd" \
        io.openshift.tags="logging,collection,fluentd" \
        License="Apache-2.0" \
        vendor="Red Hat" \
        name="openshift-logging/fluentd" \
        com.redhat.component="logging-fluentd-container" \
        io.openshift.maintainer.product="OpenShift Container Platform" \
        io.openshift.logging.fluentd.version=v1.16.2 \
        version=v1.16.2


