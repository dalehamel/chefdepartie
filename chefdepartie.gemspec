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

  spec.add_runtime_dependency 'chef', '~> 12.4', '>= 12.4.3'
  spec.add_runtime_dependency 'chef-zero', '~> 4.2', '>= 4.2.2'
  spec.add_runtime_dependency 'librarian-chef', '~> 0.0.4'
  spec.add_runtime_dependency 'cityhash', '~> 0.8.1'
  spec.add_development_dependency 'rake', ['=10.4.2']
  spec.add_development_dependency 'simplecov', ['=0.10.0']
  spec.add_development_dependency 'rspec', ['=3.4.0']
end
