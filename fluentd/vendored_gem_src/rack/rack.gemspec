# -*- encoding: utf-8 -*-
# stub: rack 3.0.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "rack".freeze
  s.version = "3.0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rack/rack/issues", "changelog_uri" => "https://github.com/rack/rack/blob/main/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/github/rack/rack", "source_code_uri" => "https://github.com/rack/rack" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Leah Neukirchen".freeze]
  s.date = "2023-03-02"
  s.description = "Rack provides a minimal, modular and adaptable interface for developing\nweb applications in Ruby. By wrapping HTTP requests and responses in\nthe simplest way possible, it unifies and distills the API for web\nservers, web frameworks, and software in between (the so-called\nmiddleware) into a single method call.\n".freeze
  s.email = "leah@vuxu.org".freeze
  s.extra_rdoc_files = ["README.md".freeze, "CHANGELOG.md".freeze, "CONTRIBUTING.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "CONTRIBUTING.md".freeze, "MIT-LICENSE".freeze, "README.md".freeze, "SPEC.rdoc".freeze, "lib/rack.rb".freeze, "lib/rack/auth/abstract/handler.rb".freeze, "lib/rack/auth/abstract/request.rb".freeze, "lib/rack/auth/basic.rb".freeze, "lib/rack/auth/digest.rb".freeze, "lib/rack/auth/digest/md5.rb".freeze, "lib/rack/auth/digest/nonce.rb".freeze, "lib/rack/auth/digest/params.rb".freeze, "lib/rack/auth/digest/request.rb".freeze, "lib/rack/body_proxy.rb".freeze, "lib/rack/builder.rb".freeze, "lib/rack/cascade.rb".freeze, "lib/rack/chunked.rb".freeze, "lib/rack/common_logger.rb".freeze, "lib/rack/conditional_get.rb".freeze, "lib/rack/config.rb".freeze, "lib/rack/constants.rb".freeze, "lib/rack/content_length.rb".freeze, "lib/rack/content_type.rb".freeze, "lib/rack/deflater.rb".freeze, "lib/rack/directory.rb".freeze, "lib/rack/etag.rb".freeze, "lib/rack/events.rb".freeze, "lib/rack/file.rb".freeze, "lib/rack/files.rb".freeze, "lib/rack/head.rb".freeze, "lib/rack/headers.rb".freeze, "lib/rack/lint.rb".freeze, "lib/rack/lock.rb".freeze, "lib/rack/logger.rb".freeze, "lib/rack/media_type.rb".freeze, "lib/rack/method_override.rb".freeze, "lib/rack/mime.rb".freeze, "lib/rack/mock.rb".freeze, "lib/rack/mock_request.rb".freeze, "lib/rack/mock_response.rb".freeze, "lib/rack/multipart.rb".freeze, "lib/rack/multipart/generator.rb".freeze, "lib/rack/multipart/parser.rb".freeze, "lib/rack/multipart/uploaded_file.rb".freeze, "lib/rack/null_logger.rb".freeze, "lib/rack/query_parser.rb".freeze, "lib/rack/recursive.rb".freeze, "lib/rack/reloader.rb".freeze, "lib/rack/request.rb".freeze, "lib/rack/response.rb".freeze, "lib/rack/rewindable_input.rb".freeze, "lib/rack/runtime.rb".freeze, "lib/rack/sendfile.rb".freeze, "lib/rack/show_exceptions.rb".freeze, "lib/rack/show_status.rb".freeze, "lib/rack/static.rb".freeze, "lib/rack/tempfile_reaper.rb".freeze, "lib/rack/urlmap.rb".freeze, "lib/rack/utils.rb".freeze, "lib/rack/version.rb".freeze]
  s.homepage = "https://github.com/rack/rack".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.3.26".freeze
  s.summary = "A modular Ruby webserver interface.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_development_dependency(%q<minitest-global_expectations>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<minitest-global_expectations>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end

