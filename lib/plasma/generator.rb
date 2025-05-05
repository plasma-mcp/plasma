# frozen_string_literal: true

require "fileutils"
require "erb"
require "active_support/inflector"

module Plasma
  # Handles generating new MCP server projects from templates
  class Generator
    attr_reader :name, :options

    def initialize(name, options = {})
      @name = name
      @options = options
    end

    def generate
      create_project_directory
      create_directory_structure
      generate_files_from_templates
      copy_static_files
      move_version_file
    end

    private

    def create_project_directory
      FileUtils.mkdir_p(name)
    end

    def create_directory_structure
      dirs = %w[app/prompts app/resources app/tools app/variables app/records
                config/initializers lib .github/workflows]

      dirs.each do |dir|
        dir_path = File.join(name, dir)
        FileUtils.mkdir_p(dir_path)
        FileUtils.touch(File.join(dir_path, ".gitkeep"))
      end
    end

    def templates_dir
      File.expand_path("templates", __dir__)
    end

    def move_version_file
      # Create the namespace directory
      namespace_dir = File.join(name, "lib", name.underscore)
      FileUtils.mkdir_p(namespace_dir)

      # Move the version file to the correct location
      version_file = File.join(name, "lib/version.rb")
      new_version_file = File.join(namespace_dir, "version.rb")
      return unless File.exist?(version_file)

      FileUtils.mv(version_file, new_version_file)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def generate_files_from_templates
      # Exclude example component templates and include dot files
      template_files = Dir.glob(File.join(templates_dir, "**", "*.erb"), File::FNM_DOTMATCH).reject do |file|
        result = file.include?("/app/") && file.include?("example_")
        result
      end

      template_files.each do |template_path|
        # Get relative path from templates directory
        relative_path = template_path.sub("#{templates_dir}/", "")
        # Remove .erb extension
        output_path = relative_path.sub(/\.erb$/, "")
        # Replace placeholder with actual project name
        output_path = output_path.gsub("PROJECT_NAME", name)

        # Create full path for destination
        dest_path = File.join(name, output_path)

        # Ensure directory exists
        FileUtils.mkdir_p(File.dirname(dest_path))

        # Render the template
        template = ERB.new(File.read(template_path))
        result = template.result(binding)

        # Write file
        File.write(dest_path, result)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    def copy_static_files
      static_files = Dir.glob(File.join(templates_dir, "**", "*"), File::FNM_DOTMATCH).reject do |file|
        File.directory?(file) || file.end_with?(".erb")
      end

      static_files.each do |file_path|
        relative_path = file_path.sub("#{templates_dir}/", "")
        dest_path = File.join(name, relative_path.gsub("PROJECT_NAME", name))

        FileUtils.mkdir_p(File.dirname(dest_path))
        FileUtils.cp(file_path, dest_path)
      end
    end
    # rubocop:enable Metrics/AbcSize

    def module_name
      name.gsub("-", "_").camelize
    end
  end
end

# Add extension methods for string transformations in ERB templates
class String
  unless method_defined?(:camelize)
    def camelize
      ActiveSupport::Inflector.camelize(self)
    end
  end

  unless method_defined?(:underscore)
    def underscore
      ActiveSupport::Inflector.underscore(self)
    end
  end

  unless method_defined?(:dasherize)
    def dasherize
      ActiveSupport::Inflector.dasherize(self)
    end
  end
end
