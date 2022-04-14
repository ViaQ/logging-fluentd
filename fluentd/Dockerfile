### This is a generated file from Dockerfile.in ###

#@follow_tag(registry.redhat.io/ubi8/ruby-27:latest)
FROM registry.access.redhat.com/ubi8/ruby-27
ENV BUILD_VERSION=1.14.6
ENV SOURCE_GIT_COMMIT=${CI_ORIGIN_AGGREGATED_LOGGING_UPSTREAM_COMMIT:-}
ENV SOURCE_GIT_URL=${CI_ORIGIN_AGGREGATED_LOGGING_UPSTREAM_URL:-}

ARG DATA_VERSION_VALUE=1.6.0
ARG FLUENTD_VERSION_VALUE=1.14.6
ARG CONTAINER_VALUE=oci

ENV DATA_VERSION=$DATA_VERSION_VALUE \
    FLUENTD_VERSION=$FLUENTD_VERSION_VALUE \
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH \
    container=$CONTAINER_VALUE

USER 0
RUN : 'removed yum-config-manager' \
 &&   BUILD_PKGS="make gcc-c++ libffi-devel autoconf automake libtool m4 redhat-rpm-config" \
 &&   RUNTIME_PKGS="hostname   bc  iproute" \
 &&   yum install -y --setopt=tsflags=nodocs $BUILD_PKGS $RUNTIME_PKGS \
 &&   rpm -V $BUILD_PKGS \
 &&   rpm -V $RUNTIME_PKGS \
 &&   yum clean all

ENV upstream_code=${upstream_code:-"."}
COPY  ${upstream_code}/jemalloc/ /tmp/jemalloc/
RUN pushd /tmp/jemalloc && \
        EXTRA_CFLAGS="$( rpm --eval '%{optflags}' )" ./autogen.sh && \
        make install_lib_shared install_bin && \
        cp COPYING /tmp/COPYING.jemalloc && \
    popd
RUN rm -rf /tmp/jemalloc

COPY  ${upstream_code}/source.jemalloc /source.jemalloc
RUN bash -c '. /source.jemalloc; echo jemalloc $JEMALLOC_VER >> /contents'

COPY  ${upstream_code}/vendored_gem_src/ ${HOME}/vendored_gem_src/
COPY  ${upstream_code}/lib/fluent-plugin-remote_syslog/ ${HOME}/vendored_gem_src/fluent-plugin-remote_syslog/
COPY  ${upstream_code}/lib/fluent-plugin-collected/ ${HOME}/vendored_gem_src/fluent-plugin-collected/
COPY  ${upstream_code}/lib/remote_syslog_sender/ ${HOME}/vendored_gem_src/remote_syslog_sender/
COPY  ${upstream_code}/lib/syslog_protocol/ ${HOME}/vendored_gem_src/syslog_protocol/
COPY  ${upstream_code}/install-gems.sh ${HOME}/vendored_gem_src/
COPY  ${upstream_code}/*.patch.sh ${HOME}/vendored_gem_src/
COPY  ${upstream_code}/*.patch ${HOME}/vendored_gem_src/

RUN cd ${HOME}/vendored_gem_src/ && ./install-gems.sh && cd / 
RUN rm -rf ${HOME}/vendored_gem_src/

RUN BUILD_PKGS="make gcc-c++ libffi-devel \
                gcc gcc-gdb-plugin cpp \
                nodejs \
                autoconf automake libtool m4 \
                redhat-rpm-config rubygem-bundler" && \
    yum remove -y $BUILD_PKGS

RUN mkdir -p /etc/fluent/plugin

COPY  ${upstream_code}/out_syslog_buffered.rb /etc/fluent/plugin/
COPY  ${upstream_code}/out_syslog.rb /etc/fluent/plugin/
COPY  ${upstream_code}/out_rawtcp.rb /etc/fluent/plugin/

COPY  ${upstream_code}/run.sh ${HOME}/
COPY  ${upstream_code}/generate_syslog_config.rb ${HOME}/
COPY  ${upstream_code}/wait_for_es_version.rb ${HOME}/
COPY  ${upstream_code}/wait_for_es_version.sh ${HOME}/

COPY  ${upstream_code}/lib/filter_parse_json_field/lib/*.rb /etc/fluent/plugin/
COPY  ${upstream_code}/lib/filter_elasticsearch_genid_ext/lib/filter_elasticsearch_genid_ext.rb /etc/fluent/plugin/
COPY  ${upstream_code}/lib/parser_viaq_host_audit/lib/*.rb /etc/fluent/plugin/
COPY  ${upstream_code}/lib/fluent-plugin-viaq_data_model/lib/fluent/plugin/*.rb /etc/fluent/plugin/
COPY  ${upstream_code}/lib/formatter-single-json-value/lib/*.rb /etc/fluent/plugin/
COPY  ${upstream_code}/utils/ /usr/local/bin/

RUN mkdir -p /etc/fluent/configs.d/user && \    
    chmod 777 /etc/fluent/configs.d/user && \    
    ln -s /etc/fluent/configs.d/user/fluent.conf /etc/fluent/fluent.conf 

WORKDIR ${HOME}
CMD ["sh", "run.sh"]

LABEL \
        License="Apache-2.0" \
        io.k8s.description="Fluentd container for collecting of container logs" \
        io.k8s.display-name="Fluentd" \
        io.openshift.tags="logging,collection,fluentd" \
        vendor="Red Hat" \
        name="openshift-logging/fluentd-rhel8" \
        com.redhat.component="logging-fluentd-container" \
        io.openshift.maintainer.product="OpenShift Container Platform" \
        io.openshift.build.commit.id=${CI_ORIGIN_AGGREGATED_LOGGING_UPSTREAM_COMMIT} \
        io.openshift.build.source-location=${CI_ORIGIN_AGGREGATED_LOGGING_UPSTREAM_URL} \
        io.openshift.build.commit.url=${CI_ORIGIN_AGGREGATED_LOGGING_UPSTREAM_URL}/commit/${CI_ORIGIN_AGGREGATED_LOGGING_UPSTREAM_COMMIT} \
        version=v1.14.5

