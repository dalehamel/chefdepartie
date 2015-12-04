require 'simplecov'
SimpleCov.start
require 'rspec'
require 'tmpdir'

require File.expand_path('../../lib/chefdepartie.rb', __FILE__)

FIXTURE_PATH = File.expand_path('../fixtures', __FILE__)

def chef_config
  {
    encrypted_data_bag_secret: File.join(FIXTURE_PATH, 'encrypted_data_bag_secret'),
    cookbook_path: File.join(FIXTURE_PATH, 'cookbooks', 'cookbooks'), # FIXME
    chef_server_url: "http://#{my_ip}:#{get_free_port}",
  }

end

def with_server
  Chefdepartie::Server.configure(config: chef_config)

  Chefdepartie::Server.start
  yield
  Chefdepartie::Server.stop
end

def match_fixture(name, actual)
  path = File.expand_path("fixtures/#{name}.txt", File.dirname(__FILE__))
  File.open(path, 'w') { |f| f.write(actual) } if ENV['FIXTURE_RECORD']
  expect(actual).to eq(File.read(path))
end

def my_ip
  Socket.ip_address_list.find{|x| x.ipv4? && !x.ipv4_loopback? && !x.ip_address.start_with?('169.254')}.ip_address
end

def get_free_port
  socket = Socket.new(:INET, :STREAM, 0)
  socket.bind(Addrinfo.tcp("127.0.0.1", 0))
  port = socket.local_address.ip_port
  socket.close
  port
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
