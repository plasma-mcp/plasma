# frozen_string_literal: true

require "model_context_protocol"

module Plasma
  # Handles MCP server operations
  class Server
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def start
      # Check if we're in a PLASMA project directory
      unless plasma_project?
        puts "Error: Not a PLASMA project directory. Please run this command from the root of a PLASMA project."
        return false
      end

      # Load the application
      app_class = load_application

      # Start the MCP server
      app_class.start_server

      true
    rescue Interrupt
      # puts "\nShutting down MCP server..."
    end

    private

    def plasma_project?
      File.exist?("config/application.rb") &&
        File.exist?("config/boot.rb") &&
        Dir.exist?("app/prompts") &&
        Dir.exist?("app/resources") &&
        Dir.exist?("app/tools")
    end

    def load_application
      require_relative "loader"
      Plasma::Loader.load_project
    end
  end
end
