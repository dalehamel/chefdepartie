require File.expand_path('../../spec_helper.rb', __FILE__)

RSpec.describe Chefdepartie::Runner do
  context 'clients' do
    it 'can upload fixtures' do
      expect{Chefdepartie.run(background: true, config: chef_config)}.to output(/Ready/).to_stdout
    end

    it 'can cache uploads' do
      cache = Dir.mktmpdir
      expect{Chefdepartie.run(background: true, config: chef_config, cache: cache)}.to output(/Ready/).to_stdout
      expect{Chefdepartie.run(background: true, config: chef_config, cache: cache)}.to output("Uploading roles\nUploading databags\nUploading dependency cookbooks\nUploading site cookbooks\nReady\n").to_stdout
    end
  end
end
