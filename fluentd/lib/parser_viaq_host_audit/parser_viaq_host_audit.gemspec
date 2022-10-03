# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# can override for testing
FLUENTD_VERSION = ENV['FLUENTD_VERSION'] || "1.14.6" unless Object.const_defined?(:FLUENTD_VERSION)

Gem::Specification.new do |gem|
  gem.name          = "parser_viaq_host_audit"
  gem.version       = "0.0.2"
  gem.authors       = ["Red Hat, Inc."]
  gem.email         = ["team-logging@redhat.com"]
  gem.summary       = %q{Parser plugin to read linux audit records coming from auditd}
  gem.files         = Dir['lib/**/*']
  gem.required_ruby_version = '>= 2.0.0'

  gem.add_runtime_dependency "fluentd", "~> #{FLUENTD_VERSION}"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency("fluentd", "~> #{FLUENTD_VERSION}")
  gem.add_development_dependency("rake", ["~> 11.0"])
  gem.add_development_dependency("rr", ["~> 1.0"])
  gem.add_development_dependency("test-unit", ["~> 3.2"])
  gem.add_development_dependency("test-unit-rr", ["~> 1.0"])
end
