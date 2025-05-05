# frozen_string_literal: true

require "thor"
require "fileutils"
require "zeitwerk"

module Plasma
  # CLI interface for the plasma-mcp gem
  class CLI < Thor
    desc "new NAME", "Create a new MCP server project"
    method_option :skip_git, type: :boolean, default: false, desc: "Skip Git initialization"
    def new(name)
      generator = Generator.new(name, options)
      generator.generate

      return if options[:skip_git]

      Dir.chdir(name) do
        system("git init .")
      end
    end

    desc "server [/path/to/your/plasma/project]", "Launch your MCP server from the specified project path"
    def server(path = nil)
      # Change to the specified path if provided
      Dir.chdir(path) if path

      # Start the server
      server = Server.new(options)
      server.start
    end

    # Alias for server
    map "s" => :server

    desc "auth", "Launch the local authentication beacon"
    method_option :port, type: :numeric, desc: "Port to run the auth server on"
    method_option :host, type: :string, desc: "Host to bind the auth server to"
    def auth
      puts "Engaging local authentication system..."

      # Start the auth server with options
      auth = Auth.new(options)
      auth.start
    end

    desc "console", "Start an interactive console with your PLASMA application loaded"
    def console
      require "debug"

      # Load the application so we can use it in the console if we need to
      require_relative "loader"
      _application = Plasma::Loader.load_project

      # Start an interactive console
      binding.irb # rubocop:disable Lint/Debugger
    end

    desc "version", "Show PLASMA version"
    def version
      puts "PLASMA version #{Plasma::VERSION}"
    end

    # Generator commands
    desc "generate TYPE NAME [PARAMETERS]", "Generate a new component (tool, prompt, resource, or variable)"
    def generate(type, name, *parameters)
      # Parse parameters into a hash
      params = {}
      parameters.each do |param|
        key, value = param.split(":")
        params[key] = value if key && value
      end

      # Create the generator
      generator = ComponentGenerator.new(type, name, params)
      generator.generate
    end

    # Alias for generate
    map "g" => :generate

    private

    def plasma_project?
      File.exist?("config/application.rb") &&
        File.exist?("config/boot.rb") &&
        Dir.exist?("app/prompts") &&
        Dir.exist?("app/resources") &&
        Dir.exist?("app/tools") &&
        Dir.exist?("app/variables")
    end
  end
end
