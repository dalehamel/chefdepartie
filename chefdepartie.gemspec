lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chefdepartie/version'

Gem::Specification.new do |s|
  s.name        = 'chefdepartie'
  s.version     = Chefdepartie::VERSION
  s.summary     = 'chefdepartie helps you test you cookbooks locally'
  s.description = 'chefdepartie uses chef-zero to provide a local, testing chef server'
  s.authors     = ['Dale Hamel']
  s.email       = 'dale.hamel@srvthe.net'
  s.files       = Dir['lib/**/*']
  s.homepage    = 'https://rubygems.org/gems/chefdepartie'
  s.license     = 'MIT'

  s.add_runtime_dependency 'chef', ['=12.9.38']
  s.add_runtime_dependency 'chef-zero', '~> 4.2', '>= 4.2.2'
  s.add_runtime_dependency 'librarian-chef', '~> 0.0.4'
  s.add_runtime_dependency 'cityhash', '~> 0.8.1'
  s.add_development_dependency 'rake', ['=10.4.2']
  s.add_development_dependency 'simplecov', ['=0.10.0']
  s.add_development_dependency 'rspec', ['=3.4.0']
end
