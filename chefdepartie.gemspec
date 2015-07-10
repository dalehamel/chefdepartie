lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chefdepartie/version'

Gem::Specification.new do |spec|
  spec.name        = 'chefdepartie'
  spec.version     = Chefdepartie::VERSION
  spec.summary     = 'chefdepartie helps you test you cookbooks locally'
  spec.description = 'chefdepartie uses chef-zero to provide a local, testing chef server'
  spec.authors     = ['Dale Hamel']
  spec.email       = 'dale.hamel@srvthe.net'
  spec.files       = Dir['lib/**/*']
  spec.homepage    = 'https://rubygems.org/gems/chefdepartie'
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'chef', '~> 12.3.0'
  spec.add_runtime_dependency 'chef-zero', '~> 4.2.2'
  spec.add_runtime_dependency 'librarian-chef', '~> 0.0.4'
  spec.add_development_dependency 'minitest', '~> 5.6'
end
