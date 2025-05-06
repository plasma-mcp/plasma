# frozen_string_literal: true

require "active_support/core_ext/module/introspection"
require "active_support/core_ext/class/subclasses"
require "model_context_protocol"
require "zeitwerk"
require "sinatra/base"
require "omniauth"
require "securerandom"

module Plasma
  # Base application class for PLASMA applications
  class Application
    class << self
      attr_accessor :config, :registry, :server

      # Initialize the application
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      def initialize!
        # Set up configuration
        @config ||= Configuration.new
        yield @config if block_given?

        # Set default name based on module name if not explicitly set
        if @config.name.nil?
          module_name = to_s.split("::").first
          @config.name = "#{module_name} MCP Server"
        end

        # Set up autoloading
        module_name = module_parent.name
        loader = Zeitwerk::Loader.new
        loader.push_dir("./app", namespace: Object.const_get(module_name))
        loader.push_dir(File.expand_path("../plasma", __dir__), namespace: Plasma)
        loader.setup

        # Load prompts, resources, and tools
        load_all_components

        # Load the plasma auth server in case it is subclassed
        require "plasma/auth_server"

        # Create the server
        @server = ModelContextProtocol::Server.new do |config|
          config.name = @config.name || "PLASMA MCP Server"
          config.version = @config.version || "1.0.0"
          config.enable_log = @config.enable_log

          # Apply environment variables
          @config.required_env_vars.each do |var|
            config.require_environment_variable(var)
          end

          @config.env_vars.each do |key, value|
            config.set_environment_variable(key, value)
          end
        end

        # Set up the registry
        setup_registry
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

      # Start the MCP server
      def start_server
        @server.start
      end

      # Load all the application's components
      def load_all_components
        load_prompts
        load_resources
        load_tools
        load_variables
        load_records
      end

      # Find all prompt classes
      def prompts
        Prompt.descendants
      end

      # Find all resource classes
      def resources
        Resource.descendants
      end

      # Find all tool classes
      def tools
        Tool.descendants
      end

      private

      # Set up the MCP registry with all components
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def setup_registry
        @registry = ModelContextProtocol::Server::Registry.new do
          prompts list_changed: true do
            Plasma::Prompt.descendants.each do |prompt_class|
              register prompt_class
            end
          end

          resources list_changed: true, subscribe: true do
            Plasma::Resource.descendants.each do |resource_class|
              register resource_class
            end
          end

          tools list_changed: true do
            Plasma::Tool.descendants.each do |tool_class|
              register tool_class
            end
          end
        end

        # Set the registry on the server
        @server.configuration.registry = registry
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      # Find all descendants of a particular module
      def descendants_of(module_name)
        # Get the application module
        app_module = to_s.split("::").first.constantize

        # Find all classes that are defined in the specified module
        ObjectSpace.each_object(Class).select do |klass|
          klass.name&.start_with?("#{app_module}::#{module_name}::") &&
            klass != app_module.const_get(module_name)
        end
      end

      # Load all prompt files
      def load_prompts
        Dir[File.join(app_root, "app/prompts/**/*.rb")].each { |f| require f }
      end

      # Load all resource files
      def load_resources
        Dir[File.join(app_root, "app/resources/**/*.rb")].each { |f| require f }
      end

      # Load all tool files
      def load_tools
        Dir[File.join(app_root, "app/tools/**/*.rb")].each { |f| require f }
      end

      # Load all variable files
      def load_variables
        Dir[File.join(app_root, "app/variables/**/*.rb")].each { |f| require f }
      end

      # Load all record files
      def load_records
        Dir[File.join(app_root, "app/records/**/*.rb")].each { |f| require f }
      end

      # Get the application root directory
      def app_root
        # Default to the current directory
        Dir.pwd
      end
    end

    # Configuration class for PLASMA applications
    class Configuration
      attr_accessor :name, :version, :enable_log, :module_name, :auth_port, :auth_host, :omniauth_provider_args
      attr_reader :required_env_vars, :env_vars

      def initialize
        @name = nil
        @version = nil
        @enable_log = true
        @module_name = nil
        @required_env_vars = []
        @env_vars = {}
        @auth_port = 4567
        @auth_host = "localhost"
        @omniauth_provider_args = {}
      end

      def require_environment_variable(name)
        @required_env_vars << name
      end

      def set_environment_variable(name, value)
        @env_vars[name] = value
      end
    end
  end
end
