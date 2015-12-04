require 'chef_zero/server'
require 'uri/generic'

module Chefdepartie

  module Server
    extend self
    def start_server(background, cache: nil)
      port = URI(Chef::Config[:chef_server_url]).port
      opts = { host: '0.0.0.0', port: port }#, log_level: :debug }
      opts.merge!({data_store: Cache.setup(cache) }) if cache
      server = ChefZero::Server.new(opts)

      if background
        server.start_background
        server
      else
        Thread.new do
          server.start
        end
      end
    end
  end
end
