# frozen_string_literal: true

require "puma"

module Plasma
  # Handles authentication operations
  class Auth
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def start
      puts "Starting authentication server..."

      return error_not_plasma_project unless plasma_project?

      application = Plasma::Loader.load_project
      config = application.config

      port, host = resolve_port_and_host(config)
      auth_server_class = resolve_auth_server_class(application)
      puma_auth_server = Puma::Server.new(auth_server_class.new)
      puma_auth_server.add_tcp_listener(host, port)

      run_and_wait_for_shutdown(puma_auth_server, auth_server_class)

      # TODO: check if the config vars have actually been set
      puts "Authentication server succesfully shutdown."
    end

    private

    def error_not_plasma_project
      puts "Error: Not a PLASMA project directory. Please run this command from the root of a PLASMA project."
      false
    end

    def resolve_port_and_host(config)
      [
        @options[:port] || config.auth_port || 4567,
        @options[:host] || config.auth_host || "localhost"
      ]
    end

    def resolve_auth_server_class(application)
      application.module_parent.const_get("AuthServer")
    end

    def run_and_wait_for_shutdown(puma_auth_server, auth_server_class)
      puma_auth_server.run
      Timeout.timeout(300) do
        sleep 0.1 until auth_server_class.ready_to_shutdown?
      rescue Timeout::Error
        puts "Authentication server did not shutdown in time. Forcing shutdown."
      end
      puma_auth_server.halt
    end

    def plasma_project?
      File.exist?("config/application.rb") &&
        File.exist?("config/boot.rb") &&
        Dir.exist?("app/prompts") &&
        Dir.exist?("app/resources") &&
        Dir.exist?("app/tools")
    end

    def start_auth_server
      puts "Starting authentication server on #{options[:host]}:#{options[:port]}..."
      puts "This is a placeholder for the actual authentication server."
      puts "In a real implementation, this would start a server with OAuth endpoints."

      # This is a placeholder for the actual authentication server implementation
      loop do
        sleep 1
      end
    rescue Interrupt
      puts "\nShutting down authentication server..."
    end
  end
end
