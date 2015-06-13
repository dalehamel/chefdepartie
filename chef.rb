require 'chef/environment'
require 'chef/role'
require 'chef/cookbook/metadata'
require 'chef/cookbook_uploader'
require 'chef'
require 'librarian'
require 'librarian/chef'
require 'chef_zero/server'

def start_server
  server = ChefZero::Server.new(port: 4000)
  server.start_background
end

def upload_cookbooks(path, books)
  loader = Chef::CookbookLoader.new(path)

  books = books.collect do |name|
    status = :new
    cookbook = loader.load_cookbook(name)
    raise "could not load cookbook #{name} " if cookbook.nil?
    cookbook
  end.compact

  rest = Chef::REST.new("http://localhost:4000")

  begin
    Chef::CookbookUploader.new(books, {force: true, rest: rest}).upload_cookbooks
  rescue SystemExit => e
    raise "Cookbook upload exited with status #{e.status}"
  end

  books.map(&:name).map(&:to_s)
end

def upload_site_cookbooks(books)
  paths = {}
  books.each do |book|
    path, book = book.split('/', 2)
    paths[path] ||= []
    paths[path] << book
  end

  paths.each do |path, books|
    upload_cookbooks(path, books)
  end

  paths.values.flatten.uniq.sort
end

def upload_cheffile
  unless ENV['NO_LIBRARIAN']
    system("librarian-chef install")
    upload_cookbooks("tmp/librarian/cookbooks", cheffile_cookbooks.map(&:name))
  end
end

def cheffile_cookbooks
  librarian = ::Librarian::Chef.environment_class.new
  librarian.lock.manifests
end

def upload_site_roles(files)
  roles = {}
  files.each do |f|
    role = role_from_file(f)
    roles[role.name] = role # original name as hash key
    role.name(role.name)
  end

  upload_roles(roles.values)

  roles
end

def role_from_file(file)
  role = Chef::Role.new
  puts file
  role.from_file(file)
  role
end

def upload_roles(roles)
  roles.each do |role|
    role.save
    puts "Uploaded #{role.name.inspect} role."
  end
end

def main
  start_server
  Chef::Config.from_file('config.rb')
  Dir.chdir("cookbooks")
  books = Dir["cookbooks/*"]
  roles = []
  Find.find('roles'){ |f| roles << f if f =~ /\.rb$/}
  upload_site_roles(roles)
  puts "Uploading librarian cookbooks"
  upload_cheffile
  puts "Uploading site cookbooks"
  upload_site_cookbooks(books)
end

main
puts "Ready"
sleep 60000
