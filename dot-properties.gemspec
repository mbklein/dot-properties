# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dot_properties/version'

Gem::Specification.new do |spec|
  spec.name          = "dot-properties"
  spec.version       = DotProperties::VERSION
  spec.authors       = ["Michael B. Klein"]
  spec.email         = ["mbklein@gmail.com"]
  spec.description   = %q{Java-style .properties file manipulation with a light touch}
  spec.summary       = %q{Read/write .properties files, respecting comments and existing formatting as much as possible}
  spec.homepage      = "https://github.com/mbklein/dot-properties"
  spec.license       = "APACHE2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rdoc", ">= 2.4.2"
  spec.add_development_dependency "simplecov"
end
