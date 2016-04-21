$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'chef/rest'
require 'chefdepartie/runner'
require 'chefdepartie/server'
require 'chefdepartie/role'
require 'chefdepartie/cookbook'
require 'chefdepartie/databag'
require 'chefdepartie/cache'
