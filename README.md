# Logging Fluentd

This repo only contains the source to produce the fluentd image used by the logging subsystem for Red Hat OpenShift. [Fluentd](https://www.fluentd.org/) is a log collector that resides on each OpenShift node to gather application and node logs.  The content
was forked from [Origin Aggregated Logging](https://github.com/openshift/origin-aggregated-logging)
stack for logging releases 5.x and later. Please refer to the [cluster-logging-operator](https://github.com/openshift/cluster-logging-operator) for details regarding the operator that deploys and configures this image.  This image is intended to be run in conjunction with the configuration and `run.sh` files provided by the operator.  Experiences with the image outside that context may vary.

## Issues

Any issues can be filed at [Red Hat JIRA](https://issues.redhat.com).  Please
include as many [details](docs/issues.md) as possible in order to assist in issue resolution along with attaching a [must gather](https://github.com/openshift/cluster-logging-operator/tree/master/must-gather) output.

## Contributing
See the [hacking](HACKING.md) documentation.

## Utilities
Several utilities are available with the final image.

### sanitize_msg_chunks
Sanitize file buffer chunks by removing corrupt records.

There are known [cases](https://bugzilla.redhat.com/show_bug.cgi?id=1562004) where fluentd is stuck processing
messages that were buffered to corrupt file buffer chunks. This utility is run manually and deserializes each
file chunk, perform a limited set of operations to confirm message validity. Use this utility by:

* Stopping fluentd
* Running the utility
* Restarting fluentd

**Note:** THIS OPERATION IS DESTRUCTIVE; It will rewrite the existing file buffer chunks.  Consider backing up
the files before running this utility.