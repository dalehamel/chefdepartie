require 'chef_zero/server'
require 'uri/generic'

def start_server(background)
  port = URI(Chef::Config[:chef_server_url]).port
  server = ChefZero::Server.new(host: '0.0.0.0', port: port)

  if background
    server.start_background
    server
  else
    Thread.new do
      server.start
    end
  end
end
