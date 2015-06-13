require 'chef'

require_relative 'chefdepartie/server'
require_relative 'chefdepartie/role'
require_relative 'chefdepartie/cookbook'
require_relative 'chefdepartie/databag'

def run(**kwargs)
  config = kwargs[:config]
  cookbooks = kwargs[:cookbooks]
  start_server
  Chef::Config.from_file(config)
  Dir.chdir(cookbooks)
  books = Dir["cookbooks/*"]
  roles = []
  Find.find('roles'){ |f| roles << f if f =~ /\.rb$/}
  upload_site_roles(roles)
  puts "Uploading librarian cookbooks"
  upload_cheffile
  puts "Uploading site cookbooks"
  upload_site_cookbooks(books)
end

run(config: ENV['CHEFDEPARTIE_CONFIG'], cookbooks: ENV['CHEFDEPARTIE_COOKBOOKS'])
puts "Ready"
sleep 60000
