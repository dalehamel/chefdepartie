require 'chef'
require 'openssl'
require 'tempfile'

module Chefdepartie
  def self.run(**kwargs)
    Runner.run(kwargs)
  end

  module Runner
    extend self

    def run(**kwargs)
      # Load the configuration
      config_file = kwargs[:config_file] || ENV['CHEFDEPARTIE_CONFIG'] || ''
      load_config(config_file, kwargs[:config])
      background = kwargs[:background]

      # Start the chef-zero server
      @server_thread = Server.start_server(background, cache: kwargs[:cache])

      # Upload everything
      upload_all

      # Notify that the chef server is ready
      puts 'Ready'

      # Join the chef server thread now that everything has been uploaded
      @server_thread.join unless background
    end

    def stop
      puts 'Stopping server'
      @server_thread.stop
    end

    private

    def self.upload_all
      Chefdepartie::Roles.upload_all
      Chefdepartie::Databags.upload_all
      Chefdepartie::Cookbooks.upload_all
    end

    def self.load_config(config_file, config)
      # Load config from config file if provided
      Chef::Config.from_file(config_file) if !config_file.empty? && File.exist?(config_file)

      # Load config from hash
      if config && config.is_a?(Hash)
        config[:node_name] ||= 'chef-zero'
        unless config[:client_key]
          client_key = Tempfile.new('chef-zero-client')
          client_key.write(OpenSSL::PKey::RSA.new(2048).to_s)
          client_key.close
          config[:client_key] = client_key.path
        end
        config.each do |k, v|
          Chef::Config.send(k.to_sym, v)
        end
      end
    end
  end
end
