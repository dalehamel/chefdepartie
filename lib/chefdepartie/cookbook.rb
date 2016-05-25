require 'chef'
require 'chef/cookbook/metadata'
require 'chef/cookbook_uploader'
require "chef/cookbook/syntax_check"
require 'librarian'
require 'librarian/chef'
require 'fileutils'

module Chefdepartie
  # Handle finding and uploading cookbooks
  module Cookbooks
    def self.upload_all
      cookbooks = File.dirname(Chef::Config[:cookbook_path])
      Dir.chdir(cookbooks) do
        puts 'Uploading dependency cookbooks'

        if File.exist?('Berksfile')
          upload_berksfile
        elsif File.exist?('Cheffile')
          upload_cheffile
        end

        puts 'Uploading site cookbooks'
        books = Dir['cookbooks/*']
        upload_site_cookbooks(books)
      end
    end

    private

    def self.upload_cookbooks(path, books)
      loader = Chef::CookbookLoader.new(path)

      books = books.collect do |name|
        next if Cache.cache(File.join(path, name))
        next if File.file?(File.join(path, name))
        puts "Will upload #{name}"
        cookbook = loader.load_cookbook(name)
        c = Chef::Cookbook::SyntaxCheck.for_cookbook(name, path)
        c.ruby_files.concat(c.template_files).each { |f| c.validated(f) }
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

    def self.upload_berksfile
      return if ENV['NO_BERKSHELF']

      FileUtils.mkdir_p('tmp/berkshelf/cookbooks')
      system('berks vendor tmp/berkshelf/cookbooks')
      cookbooks = Dir.entries('tmp/berkshelf/cookbooks') - %w(. ..)
      upload_cookbooks('tmp/berkshelf/cookbooks', cookbooks)
    end

    def self.upload_cheffile
      return if ENV['NO_LIBRARIAN']

      FileUtils.mkdir_p('tmp/librarian/cookbooks')
      system('librarian-chef install --quiet --path tmp/librarian/cookbooks')
      upload_cookbooks('tmp/librarian/cookbooks', cheffile_cookbooks.map(&:name))
    end

    def self.cheffile_cookbooks
      librarian = ::Librarian::Chef.environment_class.new
      librarian.lock.manifests
    end
  end
end
