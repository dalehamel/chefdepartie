require 'chef'

require_relative 'chefdepartie/server'
require_relative 'chefdepartie/role'
require_relative 'chefdepartie/cookbook'
require_relative 'chefdepartie/databag'

module Chefdepartie
  def self.run(**kwargs)

    # Load the configuration
    config = kwargs[:config]
    Chef::Config.from_file(config)

    # Start the chef-zero server
    server_thread = start_server

    # Upload everything
    upload_all

    # Now that everything has been uploaded, we'll join the server thread
    puts "Ready"
    server_thread.join
  end

private

  def self.upload_all
    Chefdepartie::Roles.upload_all
    Chefdepartie::Databags.upload_all
    Chefdepartie::Cookbooks.upload_all
  end
end

Chefdepartie.run(config: ENV['CHEFDEPARTIE_CONFIG']) # FIXME: use something better than an env var to get the config
