#! /bin/bash

set -euo pipefail

CONTAINER_ENGINE=${CONTAINER_ENGINE:-podman}

dir=$1
fullimagename=$2
tag_prefix="${OS_IMAGE_PREFIX:-"openshift/origin-"}"
dfpath=${dir}/Dockerfile

echo "----------------------------------------------------------------------------------------------------------------"
echo "-                                                                                                              -"
echo "Building image $dir - this may take a few minutes until you see any output..."
echo "-                                                                                                              -"
echo "----------------------------------------------------------------------------------------------------------------"
buildargs=""


${CONTAINER_ENGINE} --cgroup-manager=cgroupfs build $buildargs -f $dfpath -t "$fullimagename" $dir
