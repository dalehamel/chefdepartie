require 'chef_zero/server'
require 'uri/generic'

module Chefdepartie
  module Server
    extend self

    def start
      @server = ChefZero::Server.new(@opts)

      if @background
        @server.start_background
      else
        @server_thread = Thread.new do
          server.start
        end
      end
    end

    def join
      @server_thread.join unless @background
    end

    def stop
      puts 'Stopping server'
      if @background
        @server.stop if @server
      else
        @server_thread.stop if @server_thread
      end
    end

    def upload_all
      Chefdepartie::Roles.upload_all
      Chefdepartie::Databags.upload_all
      Chefdepartie::Cookbooks.upload_all
    end

    # Load chef config from hash or file
    def configure(kwargs)
      config_file = kwargs[:config_file] || ENV['CHEFDEPARTIE_CONFIG'] || ''
      # Load config from config file if provided
      Chef::Config.from_file(config_file) if !config_file.empty? && File.exist?(config_file)

      config = kwargs[:config]
      Chef::Config.log_level  :error
      # Load config from hash
      if config && config.is_a?(Hash)
        config[:node_name] ||= 'chef-zero'
        config[:client_key] ||= fake_key
        config.each do |k, v|
          Chef::Config.send(k.to_sym, v)
        end
      end

      @background = kwargs[:background]
      @cache = kwargs[:cache]

      uri = URI(Chef::Config[:chef_server_url])
      host = '0.0.0.0'
      host = '127.0.0.1' if (uri.host == '127.0.0.1' || uri.host == 'localhost') # listen on everything unless explicitly localhost.
      @opts = { host: host, port: uri.port }
      @opts.merge!(data_store: Cache.setup(@cache)) if @cache
    end

  private

    def fake_key
      client_key = Tempfile.new('chef-zero-client')
      client_key.write(OpenSSL::PKey::RSA.new(2048).to_s)
      client_key.close
      client_key.path
    end
  end
end
