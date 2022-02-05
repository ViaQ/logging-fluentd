# Troubleshooting

Following is troubleshooting information for a number of commonly identified issues with cluster logging deployments:

# All Components
## Can't resolve kubernetes.default.svc.cluster.local

This internal alias for the master should be resolvable by the included
DNS server on the master. Depending on your platform, you can run the `dig` command (perhaps in a container) against the master to
check whether this is the case:

    master$ dig kubernetes.default.svc.cluster.local @localhost
    [...]
    ;; QUESTION SECTION:
    ;kubernetes.default.svc.cluster.local. IN A

    ;; ANSWER SECTION:
    kubernetes.default.svc.cluster.local. 30 IN A   172.30.0.1

Older versions of OKD did not automatically define this internal
alias for the master. You may need to upgrade your cluster in order to
use aggregated logging. If your cluster is up to date, there may be
a problem with your pods reaching the SkyDNS resolver at the master,
or it could have been blocked from running. You must resolve this
problem before deploying again.

## Can't connect to the master or services

If DNS resolution does not return at all or the address cannot be
connected to from within a pod (e.g. the fluentd pod), this generally
indicates a system firewall/network problem and should be debugged
as such.

## Fluentd is holding onto deleted journald files that have been rotated
This [issue](https://bugzilla.redhat.com/show_bug.cgi?id=1664744) causes `/var/log` to fill up with file handles of 
deleted journald files.  The only known solution at this time is to periodically cycle Fluentd.  An OKD `CronJob` can be added to perform this function, for example, by checking every 10 minutes the amount of available space to fluentd:
```
apiVersion: v1
kind: Template
metadata:
  name: fluentd-reaper
objects:
- apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    name: fluentd-reaper
  rules:
  - apiGroups:
    - ""
    resources:
    - pods
    verbs:
    - delete
  - apiGroups:
    - ""
    resources:
    - pods/exec
    verbs:
    - create
- apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    name: fluentd-reaper
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: fluentd-reaper
  subjects:
  - kind: ServiceAccount
    name: aggregated-logging-fluentd
    namespace: ${LOGGING_NAMESPACE}
- apiVersion: batch/v1beta1
  kind: CronJob
  metadata:
    name: fluentd-reaper
    labels:
       provider: openshift
       logging-infra: fluentd-reaper
  spec:
    schedule: "${REAP_SCHEDULE}"
    jobTemplate:
      spec:
        template:
          metadata:
            labels:
              provider: openshift
              logging-infra: fluentd-reaper
          spec:
            serviceAccount: aggregated-logging-fluentd
            serviceAccountName: aggregated-logging-fluentd
            containers:
            - env:
              - name: REAP_THRESHOLD
                value: "${REAP_THRESHOLD}"
              name: cli
              image: ${CLI_IMAGE}
              command: ["/bin/bash", "-c"]
              args:
                - echo "Checking fluentd pods for space issues on /var/log...";
                  pods=$(oc get pods -l component=fluentd -o jsonpath={.items[*].metadata.name});
                  for p in $pods; do
                    echo "Checking $p...";
                    if ! $(oc get pod $p | grep Running >> /dev/null)  ; then
                      echo "$p as its not in a Running state. Skipping...";
                      continue;
                    fi;
                    space=$(oc exec -c fluentd-elasticsearch $p -- bash -c 'df --output=pcent /var/log | tail -1 | cut -d "%" -f1 | tr -d " "');
                    echo "Capacity $space";
                    if [ $space -gt ${REAP_THRESHOLD_PERCENTAGE} ] ; then
                      echo "Used capacity exceeds threshold. Deleting $p";
                      oc delete pod $p ;
                    fi;
                  done;
            restartPolicy: OnFailure
parameters:
- name: CLI_IMAGE
  value: openshift/origin-cli:latest
  description: "The image to use to execute the reaper script"
- name: REAP_THRESHOLD_PERCENTAGE
  value: "75"
  description: "The max capacity to allow for /var/log before restarting fluentd"
- name: REAP_SCHEDULE
  value: "*/30 * * * *"
  description: "The schedule to check for low disk capacity"
- name: LOGGING_NAMESPACE
  value: openshift-logging
  description: "The schedule to check for low disk capacity"


```
Create the `CronJob` by processing and applying the template:
```
$ oc process -f cron.yml  | oc apply -f -
```
**Note:** Modify the rolebinding serviceaccount namespace as needed (e.g. `logging` instead of `openshift-logging`)

See the [Kubernetes documentation](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/#suspend)  about how
to suspend this job if necessary.
