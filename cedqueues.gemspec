# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cedqueues/version'


Gem::Specification.new do |spec|
  spec.name          = "cedqueues"
  spec.version       = CedQueues::VERSION
  spec.date          = '2015-11-06'
  spec.authors       = ["Cedric Wider"]
  spec.email         = ["wider.cedric@gmail.com"]
  spec.summary       = %q{Messaging made easy}
  spec.description   = %q{Messaging really easy}
  spec.homepage      = "http://example.com"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # runtime dependencies
  spec.add_runtime_dependency 'bunny', '~> 1.6.0'

  # development dependencies
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'require_all'
end
