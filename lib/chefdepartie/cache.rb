require 'fileutils'
require 'chef'
require 'cityhash'
require 'chef_zero/data_store/raw_file_store'
require 'tmpdir'

module Chefdepartie
  module Cache
    extend self
    def setup(path)
      FileUtils.mkdir_p(File.join(path, 'organizations', 'chef'))
      @path = File.join(path, 'cache.dat')
      if File.exists?(@path) then restore  else @cache = {} end
      ds = ChefZero::DataStore::RawFileStore.new(File.join(path))
      ChefZero::DataStore::DefaultFacade.new(ds, false, false)
    end

    def cache(path)
      return false unless cache?
      hash = File.file?(path) ? CityHash.hash128(File.read(path)) : hashdir(path)
      hit = @cache[to_key(path)] == hash
      unless hit
        @cache[to_key(path)] = hash
        dump
      end
      hit
    end

    def cache?
      !@cache.nil?
    end

    def flush
      @cache = {}
      dump
    end

  private

    def hashdir(path)
      hash = ""
      Dir["#{path}/**/*"].each do |path|
        hash += CityHash.hash128(File.read(path)).to_s if File.file?(path)
      end
      CityHash.hash128(hash)
    end

    def restore
      @cache = Marshal.load(File.binread(@path))
    end

    def dump
      File.binwrite(@path, Marshal.dump(@cache))
    end

    def to_key(file)
      file.gsub(/^#{File.dirname(Chef::Config[:cookbook_path])}/,'')
    end
  end
end
