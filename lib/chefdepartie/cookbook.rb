require 'chef'
require 'chef/cookbook/metadata'
require 'chef/cookbook_uploader'
require 'librarian'
require 'librarian/chef'

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


