#!/bin/bash

set -euxo pipefail

# there is no way to disable signing using
# a flag to gem build or gem install - so just
# remove the problematic settings from the gemspec
for t in "doc" "documentation" "pkg"; do
  sed -i "s/\"$t\"\.freeze,//g" $1
done
