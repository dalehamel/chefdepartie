require 'chef'
require 'chef/cookbook/metadata'
require 'chef/cookbook_uploader'
require 'librarian'
require 'librarian/chef'

module Chefdepartie
  # Handle finding and uploading cookbooks
  module Cookbooks
    def self.upload_all
      cookbooks = File.dirname(Chef::Config[:cookbook_path])
      Dir.chdir(cookbooks) do
        puts 'Uploading librarian cookbooks'
        upload_cheffile

        puts 'Uploading site cookbooks'
        books = Dir['cookbooks/*']
        upload_site_cookbooks(books)
      end
    end

    private

    def self.upload_cookbooks(path, books)
      loader = Chef::CookbookLoader.new(path)

      books = books.collect do |name|
        status = :new
        cookbook = loader.load_cookbook(name)
        fail "could not load cookbook #{name} " if cookbook.nil?
        cookbook
      end.compact

      rest = Chef::REST.new(Chef::Config[:chef_server_url])

      begin
        Chef::CookbookUploader.new(books, force: true, rest: rest).upload_cookbooks
      rescue SystemExit => e
        raise "Cookbook upload exited with status #{e.status}"
      end

      books.map(&:name).map(&:to_s)
    end

    def self.upload_site_cookbooks(books)
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

    def self.upload_cheffile
      unless ENV['NO_LIBRARIAN']
        system('librarian-chef install')
        upload_cookbooks('tmp/librarian/cookbooks', cheffile_cookbooks.map(&:name))
      end
    end

    def self.cheffile_cookbooks
      librarian = ::Librarian::Chef.environment_class.new
      librarian.lock.manifests
    end
  end
end
