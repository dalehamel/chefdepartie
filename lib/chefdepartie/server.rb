require 'chef_zero/server'

def start_server
  server = ChefZero::Server.new(port: 4000)
  server.start_background
end

