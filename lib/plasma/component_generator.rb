# frozen_string_literal: true

require "fileutils"
require "erb"
require "active_support/inflector"
require "json"

module Plasma
  # Handles generating individual MCP components (tools, prompts, resources, variables)
  class ComponentGenerator
    attr_reader :component_type, :name, :params

    def initialize(component_type, name, params = {})
      @component_type = component_type
      @name = name
      @params = params
      @template_dir = File.expand_path("templates", __dir__)
      puts "Template directory: #{@template_dir}"
    end

    def generate
      # Check if we're in a PLASMA project directory
      unless plasma_project?
        puts "Error: Not a PLASMA project directory. Please run this command from the root of a PLASMA project."
        return false
      end

      create_component_file
      true
    end

    private

    def plasma_project?
      File.exist?("config/application.rb") &&
        File.exist?("config/boot.rb") &&
        Dir.exist?("app/prompts") &&
        Dir.exist?("app/resources") &&
        Dir.exist?("app/tools") &&
        Dir.exist?("app/variables")
    end

    def create_component_file
      template_path = find_template_path
      content = render_template(template_path)
      write_component_file(content)
    end

    def find_template_path
      path = File.join(@template_dir, "app", "#{@component_type}s", "example_#{@component_type}.rb.erb")
      raise "Template not found at: #{path}" unless File.exist?(path)

      path
    end

    def render_template(template_path)
      template = ERB.new(File.read(template_path), trim_mode: "-")
      template.result(binding)
    end

    def write_component_file(content)
      component_dir = File.join("app", "#{@component_type}s")
      FileUtils.mkdir_p(component_dir)

      file_path = File.join(component_dir, "#{@name.downcase}_#{@component_type}.rb")
      File.write(file_path, content)
    end

    def module_name
      # Get the application module name from the current directory
      File.basename(Dir.pwd).gsub("-", "_").camelize
    end

    def parameter_schema
      return {} if params.empty?

      schema = {
        type: "object",
        properties: params.transform_values { |type| { type: type } },
        required: params.keys
      }

      JSON.pretty_generate(schema)
    end

    # Convert the name to the appropriate format for the file
    def file_name
      # Convert camelCase to snake_case and append _tool
      "#{@name.underscore}_#{@component_type}"
    end

    # Convert the name to kebab-case for the metadata
    def kebab_name
      @name.underscore.gsub("_", "-")
    end

    def component_class_name
      @name.split("_").map(&:capitalize).join
    end

    def component_name
      @name.downcase
    end

    def parameter_definitions
      @params.map do |name, type|
        "#{name}: { type: \"#{type}\" }"
      end.join(",\n    ")
    end

    # For variable templates
    def default_value
      # Use the 'default' parameter if provided, otherwise use a sensible default based on variable type
      if params.key?("default")
        # If it's a string, wrap in quotes
        if params["default"].is_a?(String) || !%w[true false null].include?(params["default"].downcase)
          "\"#{params["default"]}\""
        else
          params["default"]
        end
      else
        # Default to empty string if no default provided
        "\"\""
      end
    end

    # For variable templates - operations like increment, decrement, etc.
    def operations
      return [] unless @component_type == "variable"

      # Define standard operations based on params
      ops = []

      # Add increment/decrement for numeric variables
      if params.values.any? { |type| %w[number integer].include?(type) }
        ops << { name: "increment", params: ["value"], operator: "+" }
        ops << { name: "decrement", params: ["value"], operator: "-" }
      end

      # Add append for string variables
      if params.values.any? { |type| type == "string" } || params.empty?
        ops << { name: "append", params: ["value"], operator: "+" }
      end

      ops
    end
  end
end
