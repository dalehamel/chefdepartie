require 'chef'
require 'openssl'
require 'tempfile'

module Chefdepartie
  def self.run(**kwargs)
    Runner.run(kwargs)
  end

  def self.stop
    Server.stop
  end

  module Runner
    extend self

    def run(**kwargs)
      # Load the configuration
      Server.configure(kwargs)

      # Start the chef-zero server
      Server.start

      # Upload everything
      Server.upload_all

      # Notify that the chef server is ready
      puts 'Ready'

      # Join the chef server thread now that everything has been uploaded
      Server.join
    end
  end
end
