# frozen_string_literal: true

module Plasma
  # Handles loading PLASMA projects
  class Loader
    def self.load_project
      # Load the application boot file
      require_relative File.join(Dir.pwd, "config/boot")

      # Determine the application class name
      app_name = File.basename(Dir.pwd).gsub("-", "_").camelize

      # Load the application
      require_relative File.join(Dir.pwd, "config/application")

      # Get the application module and include it in the top-level scope
      app_module = Object.const_get(app_name)
      Object.include(app_module)

      # Return the application class
      Object.const_get("#{app_name}::Application")
    rescue LoadError, NameError => e
      handle_load_error(e)
    end

    def self.handle_load_error(error)
      message = error.is_a?(LoadError) ? "Error loading application" : "Error initializing application"
      puts "#{message}: #{error.message}"
      raise error
    end
  end
end
