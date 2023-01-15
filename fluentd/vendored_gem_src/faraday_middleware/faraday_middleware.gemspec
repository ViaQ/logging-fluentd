# -*- encoding: utf-8 -*-
# stub: faraday_middleware 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "faraday_middleware".freeze
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Erik Michaels-Ober".freeze, "Wynn Netherland".freeze]
  s.date = "2021-10-14"
  s.email = ["sferik@gmail.com".freeze, "wynn.netherland@gmail.com".freeze]
  s.files = ["LICENSE.md".freeze, "README.md".freeze, "lib/faraday_middleware.rb".freeze, "lib/faraday_middleware/backwards_compatibility.rb".freeze, "lib/faraday_middleware/gzip.rb".freeze, "lib/faraday_middleware/instrumentation.rb".freeze, "lib/faraday_middleware/rack_compatible.rb".freeze, "lib/faraday_middleware/redirect_limit_reached.rb".freeze, "lib/faraday_middleware/request/encode_json.rb".freeze, "lib/faraday_middleware/request/method_override.rb".freeze, "lib/faraday_middleware/request/oauth.rb".freeze, "lib/faraday_middleware/request/oauth2.rb".freeze, "lib/faraday_middleware/response/caching.rb".freeze, "lib/faraday_middleware/response/chunked.rb".freeze, "lib/faraday_middleware/response/follow_redirects.rb".freeze, "lib/faraday_middleware/response/mashify.rb".freeze, "lib/faraday_middleware/response/parse_dates.rb".freeze, "lib/faraday_middleware/response/parse_json.rb".freeze, "lib/faraday_middleware/response/parse_marshal.rb".freeze, "lib/faraday_middleware/response/parse_xml.rb".freeze, "lib/faraday_middleware/response/parse_yaml.rb".freeze, "lib/faraday_middleware/response/rashify.rb".freeze, "lib/faraday_middleware/response_middleware.rb".freeze, "lib/faraday_middleware/version.rb".freeze]
  s.homepage = "https://github.com/lostisland/faraday_middleware".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.3.26".freeze
  s.summary = "Various middleware for Faraday".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<faraday>.freeze, ["~> 1.0"])
  else
    s.add_dependency(%q<faraday>.freeze, ["~> 1.0"])
  end
end

