require 'chef'

require_relative 'chefdepartie/server'
require_relative 'chefdepartie/role'
require_relative 'chefdepartie/cookbook'
require_relative 'chefdepartie/databag'

# Chefdepartie root namespace for core module commands
module Chefdepartie
  def self.run(**kwargs)
    # Load the configuration
    config_file = kwargs[:config_file] || ENV['CHEFDEPARTIE_CONFIG']
    load_config(config_file, kwargs[:config])
    background = kwargs[:background]

    # Start the chef-zero server
    self.server_thread = start_server(background)

    # Upload everything
    upload_all

    # Notify that the chef server is ready
    puts 'Ready'

    # Join the chef server thread now that everything has been uploaded
    self.server_thread.join unless background
  end

  def self.stop
    puts 'Stopping server'
    server_thread.stop
  end

  private

  def self.server_thread=(thread)
    @@server_thread = thread
  end

  def self.server_thread
    @@server_thread
  end

  def self.upload_all
    Chefdepartie::Roles.upload_all
    Chefdepartie::Databags.upload_all
    Chefdepartie::Cookbooks.upload_all
  end

  def self.load_config(config_file, config)
    # Load config from config file if provided
    Chef::Config.from_file(config_file) if File.exist?(config_file)

    # Load config from hash
    if config && config.is_a?(Hash)
      config.each do |k, v|
        Chef::Config.send(k.to_sym, v)
      end
    end
  end
end
