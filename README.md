# Logging Fluentd

This repo only contains the source to produce the fluentd image used by the logging subsystem for Red Hat OpenShift. The content
was forked from [Origin Aggregated Logging](https://github.com/openshift/origin-aggregated-logging)
stack for releases 4.x and later. Please refer to the [cluster-logging-operator](https://github.com/openshift/cluster-logging-operator) for details regarding the operator that deploys and configures this image.  

## Issues

Any issues can be filed at [Red Hat JIRA](https://issues.redhat.com).  Please
include as many [details](docs/issues.md) as possible in order to assist in issue resolution along with attaching a [must gather](https://github.com/openshift/cluster-logging-operator/tree/master/must-gather) output.

## Hacking

Building the image requires docker and [imagebuilder](https://github.com/openshift/imagebuilder).  There is currently an issue using podman and trying to remove directories while building 