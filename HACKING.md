# Hacking
Building the image requires docker and [imagebuilder](https://github.com/openshift/imagebuilder).  There is currently an issue using podman and trying to remove directories while building . This repo vendors the dependencies required to build the final image. Following are instructions for hacking on fluentd.

## Directories

Dependencies are organized according in several basic directories under the fluentd directory:
* `lib` - Dependencies for which this repo is considered the single source of truth.  This is where we make changes that are permanent forks of other libraries or libraries that do not have any other upstream
* `vendored_gem_src` - Dependencies that are copied in from upstream sources based on what is defined in the `Gemfile`.  Changes should never be made to content in this directory as it is likely to be clobbered on updates
* `jemalloc` - The memory management library used at runtime

## Updating jemalloc

 Edit the file `fluentd/source.jemalloc` to also update the
vendored jemalloc source.  You will have to use `git add` or `git rm` or otherwise
fix any conflicts, then commit and submit a PR.

## Modifying a gem Dependency

Modifying or updating any of the gems requires a local ruby installation.
The version of ruby should match the ruby version in the first line of `Dockerfile`.
It is highly recommended to setup the environment using something like [rvm](https://rvm.io/) which makes it possible to install multiple versions of ruby and define sets of gems.

### Install Ruby

The version of ruby should match the ruby version of the `FROM` line of the `Dockerfile`.

```
rvm install ruby-2.5
rvm use ruby-2.5
```

### Install Vendored Gems

Gems required by fluentd are maintained in the [Gemfile](https://bundler.io/gemfile.html) which is the list of dependencies. The repository also includes the `Gemfile.lock` which is the explicit list of the versions of the dependencies being used including the transitive ones.

Note the bundler version should match the version from the end of `Gemfile.lock`

```
rvm gemset create fluentd
rvm gemset use fluentd
gem install bundler -v 1.17.3
bundle install
```

### Updating Vendored Gems

* Edit `Gemfile` to add new gems.
* Run the update script from the repo root dir
  ```
  cd ..
  ./hack/update-fluentd-vendor-gems.sh
  ```
* Commit changes and rebuild images

**Note:** The hack script accepts the following env vars:

* `BUNDLE_TASK=install`: (default) download and install all missing Gems.
* `BUNDLE_TASK=update SOMEGEM` : update a single gem to latest.
* `BUNDLE_TASK=update` : update _all_ the gems to latest.
  **Note**: Not to be undertaken lightly!
* `CLOBBER_VENDOR`: If set remove everything in `vendored_gem_src` for cases where the intent is to clean up the vendored gems to remove unused dependencies

If you get an error like this:

``` shell
[32mFetching fluent-plugin-kafka 0.13.1[0m
[31mDownloading fluent-plugin-kafka-0.13.1 revealed dependencies not in the API or the lockfile
(fluentd (>= 0.10.58, < 2)).
```

This may help (replace the plugin name and version appropriately)
``` shell
gem uninstall fluent-plugin-kafka
gem install fluent-plugin-kafka --version 0.13.1
```

### Make lib Changes

* May need to install additional dependencies from `lib/<gemdir>` using `bundle install`
* Make any needed changes to the files in lib
* Test change `bundle exec rake test`
* Commit change and rebuild image

## Building the Container Image
```
$ make image
```

## Deploying to OpenShift

See the [cluster-logging-operator](https://github.com/openshift/cluster-logging-operator/blob/master/docs/HACKING.md) hacking document for deploying OpenShift Logging using the operator make targets.
