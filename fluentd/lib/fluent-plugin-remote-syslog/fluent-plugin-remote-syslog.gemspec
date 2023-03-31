# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-remote-syslog"
  gem.description = "Output plugin for streaming logs out to a remote syslog"
  gem.homepage    = "https://github.com/docebo/fluent-plugin-remote-syslog"
  gem.summary     = "This plugin was modified to support RH OpenShift Logging"
  gem.version     = "1.2"
  gem.authors     = ["Andrea Spoldi"]
  gem.email       = "devops@docebo.com"
  gem.license     = 'MIT'
  gem.files       =  Dir['lib/**/*']
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_runtime_dependency "fluentd", "=1.14.6"
  gem.add_dependency "fluent-mixin-config-placeholders"
  gem.add_dependency "syslog_protocol"
  gem.add_development_dependency "rake", ">= 0.9.2"
  gem.add_development_dependency("test-unit", ["~> 3.2"])
end
