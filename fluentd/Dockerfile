FROM registry.access.redhat.com/ubi9/ruby-31 AS builder


USER 0
RUN : 'removed yum-config-manager' \
 &&   BUILD_PKGS="make gcc-c++ libffi-devel autoconf automake libtool m4 redhat-rpm-config libxml2-devel" \
 &&   RUNTIME_PKGS="hostname bc iproute" \
 &&   dnf install -y --setopt=tsflags=nodocs $BUILD_PKGS $RUNTIME_PKGS \
 &&   rpm -V $BUILD_PKGS \
 &&   rpm -V $RUNTIME_PKGS \
 &&   dnf clean all

WORKDIR /opt/app-root/src
COPY . .


RUN CONFIGURE_ARGS="--with-cflags='$( rpm --eval %optflags )'" bundle install


FROM registry.access.redhat.com/ubi9/ruby-31 AS runtime

ENV BUILD_VERSION=1.14.6
ENV OS_GIT_MAJOR=1
ENV OS_GIT_MINOR=14
ENV OS_GIT_PATCH=6

ARG DATA_VERSION_VALUE=1.6.0
ARG FLUENTD_VERSION_VALUE=1.14.6
ARG CONTAINER_VALUE=oci

ENV DATA_VERSION=$DATA_VERSION_VALUE \
    FLUENTD_VERSION=$FLUENTD_VERSION_VALUE \
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH \
    container=$CONTAINER_VALUE

USER 0
RUN RUNTIME_PKGS="hostname bc iproute libxml2" \
 &&   dnf install -y --setopt=tsflags=nodocs $RUNTIME_PKGS \
 &&   rpm -V $RUNTIME_PKGS \
 &&   dnf clean all

RUN mkdir -p /etc/fluent/plugin

COPY --from=builder /usr/bin/fluentd /usr/bin/fluentd-orig
COPY --from=builder /usr/bin/fluent-cat /usr/bin
COPY --from=builder /usr/share/gems /usr/share/gems
COPY --from=builder /usr/lib64/gems/ruby /usr/lib64/gems/ruby
COPY --from=builder ${HOME}/lib ${HOME}/lib

COPY ./run.sh ${HOME}/
COPY ./utils/ /usr/local/bin/
COPY ./fluentd /usr/bin/

# Patch gems from upstream which are no longer vendored
COPY ./*.patch /usr/share/gems
RUN  mv /usr/share/gems/aws-sdk-core.source0001.patch /usr/share/gems/gems/aws-sdk-core-*/ && \
     cd /usr/share/gems/gems/aws-sdk-core-*/ && patch -p1 < aws-sdk-core.source0001.patch && \
     cd /usr/share/gems &&  \
     mv /usr/share/gems/fluent-plugin-detect-exceptions.source0001.patch /usr/share/gems/gems/fluent-plugin-detect-exceptions-*/ && \
     cd /usr/share/gems/gems/fluent-plugin-detect-exceptions-*/ && patch -p1 < fluent-plugin-detect-exceptions.source0001.patch

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
        name="openshift-logging/fluentd-rhel8" \
        com.redhat.component="logging-fluentd-container" \
        io.openshift.maintainer.product="OpenShift Container Platform" \
        version=v1.14.6


