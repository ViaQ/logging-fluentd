# Logging Fluentd

This repo contains only the source for the fluentd image used by the logging subsystem for Red Hat OpenShift. [Fluentd](https://www.fluentd.org/) is a log collector that resides on each OpenShift node to gather application and node logs.  The content
was forked from [Origin Aggregated Logging](https://github.com/openshift/origin-aggregated-logging)
stack for logging releases 5.x and later. Please refer to the [cluster-logging-operator](https://github.com/openshift/cluster-logging-operator) for details regarding the operator that deploys and configures this image.  This image is intended to be run in conjunction with the configuration and `run.sh` files provided by the operator.  Experiences with the image outside that context may vary.

The `main` branch is empty except for this file.  The branches used by various releases are summarized here:

| Release | Branch | fluentd Version | Ruby Version | Status |
| --------|--------|-----------------|--------|--------|
| 5.9 | v1.16.x | v1.16.2| v3.1 | Pending |
| 5.8 | v1.16.x | v1.16.2| v3.1 | Current |
| 5.7 | release-5.7|v1.14.6| v2.7 | Current |
| 5.6 | release-5.6|v1.14.6| v2.7 | Current |
| 5.5 | ruby27-v1.14.x|v1.14.6| v2.7 | EOL |
| 5.4 | v1.14.5|v1.14.5| v2.7 | EOL |


## Issues

Any issues can be filed at [Red Hat JIRA](https://issues.redhat.com).  Please
include as many details as possible in order to assist in issue resolution along with attaching the output 
from the [must gather](https://github.com/openshift/cluster-logging-operator/tree/master/must-gather) associated with the release.
