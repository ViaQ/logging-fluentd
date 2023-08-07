Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-collected"
  spec.version       = "1.1.0"
  spec.authors       = ["Red Hat, Inc."]
  spec.email         = ["team-logging@redhat.com"]
  spec.homepage      = "https://github.com/openshift/origin-aggregated-logging/tree/master/fluentd/lib/fluent-plugin-collected"
  spec.summary       = %q{A fluent plugin that collects metrics on total bytes collected by fluentd.}
  spec.description   = %q{A fluent plugin that collects metrics on total bytes collected by fluentd and exposes that for Prometheus.}
  spec.license       = "Apache-2.0"

  spec.files         = Dir['lib/**/*']
  spec.add_runtime_dependency "fluentd", "=1.16.2"
  spec.add_dependency "prometheus-client", ">=2.1.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_development_dependency "test-unit-rr", "~> 1.0"
  spec.add_development_dependency "fluent-plugin-prometheus", "~> 2.0.2"
end
