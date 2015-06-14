require 'chef_zero/server'
require 'uri/generic'

def start_server
  port = URI(Chef::Config[:chef_server_url]).port
  server = ChefZero::Server.new(port: port)
  Thread.new do
    server.start#_background
  end
end

