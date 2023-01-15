# -*- encoding: utf-8 -*-
# stub: async-http 0.59.4 ruby lib

Gem::Specification.new do |s|
  s.name = "async-http".freeze
  s.version = "0.59.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Samuel Williams".freeze, "Brian Morearty".freeze, "Bruno Sutic".freeze, "Janko Marohni\u0107".freeze, "Adam Daniels".freeze, "Cyril Roelandt".freeze, "Denis Talakevich".freeze, "Ian Ker-Seymer".freeze, "Igor Sidorov".freeze, "Marco Concetto Rudilosso".freeze, "Olle Jonsson".freeze, "Orgad Shaneh".freeze, "Stefan Wrobel".freeze, "TheAthlete".freeze, "Trevor Turk".freeze, "samshadwell".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIE2DCCA0CgAwIBAgIBATANBgkqhkiG9w0BAQsFADBhMRgwFgYDVQQDDA9zYW11\nZWwud2lsbGlhbXMxHTAbBgoJkiaJk/IsZAEZFg1vcmlvbnRyYW5zZmVyMRIwEAYK\nCZImiZPyLGQBGRYCY28xEjAQBgoJkiaJk/IsZAEZFgJuejAeFw0yMjA4MDYwNDUz\nMjRaFw0zMjA4MDMwNDUzMjRaMGExGDAWBgNVBAMMD3NhbXVlbC53aWxsaWFtczEd\nMBsGCgmSJomT8ixkARkWDW9yaW9udHJhbnNmZXIxEjAQBgoJkiaJk/IsZAEZFgJj\nbzESMBAGCgmSJomT8ixkARkWAm56MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIB\nigKCAYEAomvSopQXQ24+9DBB6I6jxRI2auu3VVb4nOjmmHq7XWM4u3HL+pni63X2\n9qZdoq9xt7H+RPbwL28LDpDNflYQXoOhoVhQ37Pjn9YDjl8/4/9xa9+NUpl9XDIW\nsGkaOY0eqsQm1pEWkHJr3zn/fxoKPZPfaJOglovdxf7dgsHz67Xgd/ka+Wo1YqoE\ne5AUKRwUuvaUaumAKgPH+4E4oiLXI4T1Ff5Q7xxv6yXvHuYtlMHhYfgNn8iiW8WN\nXibYXPNP7NtieSQqwR/xM6IRSoyXKuS+ZNGDPUUGk8RoiV/xvVN4LrVm9upSc0ss\nRZ6qwOQmXCo/lLcDUxJAgG95cPw//sI00tZan75VgsGzSWAOdjQpFM0l4dxvKwHn\ntUeT3ZsAgt0JnGqNm2Bkz81kG4A2hSyFZTFA8vZGhp+hz+8Q573tAR89y9YJBdYM\nzp0FM4zwMNEUwgfRzv1tEVVUEXmoFCyhzonUUw4nE4CFu/sE3ffhjKcXcY//qiSW\nxm4erY3XAgMBAAGjgZowgZcwCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0O\nBBYEFO9t7XWuFf2SKLmuijgqR4sGDlRsMC4GA1UdEQQnMCWBI3NhbXVlbC53aWxs\naWFtc0BvcmlvbnRyYW5zZmVyLmNvLm56MC4GA1UdEgQnMCWBI3NhbXVlbC53aWxs\naWFtc0BvcmlvbnRyYW5zZmVyLmNvLm56MA0GCSqGSIb3DQEBCwUAA4IBgQB5sxkE\ncBsSYwK6fYpM+hA5B5yZY2+L0Z+27jF1pWGgbhPH8/FjjBLVn+VFok3CDpRqwXCl\nxCO40JEkKdznNy2avOMra6PFiQyOE74kCtv7P+Fdc+FhgqI5lMon6tt9rNeXmnW/\nc1NaMRdxy999hmRGzUSFjozcCwxpy/LwabxtdXwXgSay4mQ32EDjqR1TixS1+smp\n8C/NCWgpIfzpHGJsjvmH2wAfKtTTqB9CVKLCWEnCHyCaRVuKkrKjqhYCdmMBqCws\nJkxfQWC+jBVeG9ZtPhQgZpfhvh+6hMhraUYRQ6XGyvBqEUe+yo6DKIT3MtGE2+CP\neX9i9ZWBydWb8/rvmwmX2kkcBbX0hZS1rcR593hGc61JR6lvkGYQ2MYskBveyaxt\nQ2K9NVun/S785AP05vKkXZEFYxqG6EW012U4oLcFl5MySFajYXRYbuUpH6AY+HP8\nvoD0MPg1DssDLKwXyt1eKD/+Fq0bFWhwVM/1XiAXL7lyYUyOq24KHgQ2Csg=\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2022-12-13"
  s.files = ["bake/async/http.rb".freeze, "bake/async/http/h2spec.rb".freeze, "lib/async/http.rb".freeze, "lib/async/http/body.rb".freeze, "lib/async/http/body/delayed.rb".freeze, "lib/async/http/body/hijack.rb".freeze, "lib/async/http/body/pipe.rb".freeze, "lib/async/http/body/slowloris.rb".freeze, "lib/async/http/body/writable.rb".freeze, "lib/async/http/client.rb".freeze, "lib/async/http/endpoint.rb".freeze, "lib/async/http/internet.rb".freeze, "lib/async/http/internet/instance.rb".freeze, "lib/async/http/protocol.rb".freeze, "lib/async/http/protocol/http1.rb".freeze, "lib/async/http/protocol/http1/client.rb".freeze, "lib/async/http/protocol/http1/connection.rb".freeze, "lib/async/http/protocol/http1/request.rb".freeze, "lib/async/http/protocol/http1/response.rb".freeze, "lib/async/http/protocol/http1/server.rb".freeze, "lib/async/http/protocol/http10.rb".freeze, "lib/async/http/protocol/http11.rb".freeze, "lib/async/http/protocol/http2.rb".freeze, "lib/async/http/protocol/http2/client.rb".freeze, "lib/async/http/protocol/http2/connection.rb".freeze, "lib/async/http/protocol/http2/input.rb".freeze, "lib/async/http/protocol/http2/output.rb".freeze, "lib/async/http/protocol/http2/request.rb".freeze, "lib/async/http/protocol/http2/response.rb".freeze, "lib/async/http/protocol/http2/server.rb".freeze, "lib/async/http/protocol/http2/stream.rb".freeze, "lib/async/http/protocol/https.rb".freeze, "lib/async/http/protocol/request.rb".freeze, "lib/async/http/protocol/response.rb".freeze, "lib/async/http/proxy.rb".freeze, "lib/async/http/reference.rb".freeze, "lib/async/http/relative_location.rb".freeze, "lib/async/http/server.rb".freeze, "lib/async/http/statistics.rb".freeze, "lib/async/http/version.rb".freeze]
  s.homepage = "https://github.com/socketry/async-http".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.26".freeze
  s.summary = "A HTTP client and server library.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<async>.freeze, [">= 1.25"])
    s.add_runtime_dependency(%q<async-io>.freeze, [">= 1.28"])
    s.add_runtime_dependency(%q<async-pool>.freeze, [">= 0.2"])
    s.add_runtime_dependency(%q<protocol-http>.freeze, ["~> 0.23.1"])
    s.add_runtime_dependency(%q<protocol-http1>.freeze, ["~> 0.14.0"])
    s.add_runtime_dependency(%q<protocol-http2>.freeze, ["~> 0.14.0"])
    s.add_runtime_dependency(%q<traces>.freeze, [">= 0.8.0"])
    s.add_development_dependency(%q<async-container>.freeze, ["~> 0.14"])
    s.add_development_dependency(%q<async-rspec>.freeze, ["~> 1.10"])
    s.add_development_dependency(%q<covered>.freeze, [">= 0"])
    s.add_development_dependency(%q<localhost>.freeze, [">= 0"])
    s.add_development_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.6"])
  else
    s.add_dependency(%q<async>.freeze, [">= 1.25"])
    s.add_dependency(%q<async-io>.freeze, [">= 1.28"])
    s.add_dependency(%q<async-pool>.freeze, [">= 0.2"])
    s.add_dependency(%q<protocol-http>.freeze, ["~> 0.23.1"])
    s.add_dependency(%q<protocol-http1>.freeze, ["~> 0.14.0"])
    s.add_dependency(%q<protocol-http2>.freeze, ["~> 0.14.0"])
    s.add_dependency(%q<traces>.freeze, [">= 0.8.0"])
    s.add_dependency(%q<async-container>.freeze, ["~> 0.14"])
    s.add_dependency(%q<async-rspec>.freeze, ["~> 1.10"])
    s.add_dependency(%q<covered>.freeze, [">= 0"])
    s.add_dependency(%q<localhost>.freeze, [">= 0"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.6"])
  end
end

