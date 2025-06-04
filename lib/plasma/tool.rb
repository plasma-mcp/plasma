# frozen_string_literal: true

require "model_context_protocol"
require "json"

module Plasma
  # Base tool class for PLASMA applications
  class Tool < ModelContextProtocol::Server::Tool
    class << self
      def param(name, type:, description: nil, required: false)
        @params ||= {}
        @params[name.to_sym] = {
          type: type.to_s.downcase,
          description:,
          required:
        }
      end

      def defined_params
        @params || {}
      end

      def inherited(subclass)
        super
        const_name = subclass.to_s.split("::").last
        Plasma.const_set(const_name, subclass) unless Plasma.const_defined?(const_name)
      end

      def metadata
        {
          name: to_s.split("::").last.gsub("Tool", "").underscore,
          description: extract_description,
          inputSchema: {
            type: "object",
            properties: defined_params.transform_values { |v| v.slice(:type, :description).compact },
            required: defined_params.select { |_, v| v[:required] }.keys.map(&:to_s)
          }
        }
      end

      def extract_description
        return @description if @description

        @description = read_comments_from_file(file_path).presence || "No description available"
      end

      def file_path
        loader = Zeitwerk::Registry.loaders.first
        module_name = to_s.split("::")[0..-2].join("::").constantize
        class_name = to_s.split("::").last.to_sym
        path = loader.instance_variable_get(:@inceptions).instance_variable_get(:@map)[module_name][class_name]
        return nil unless path

        File.expand_path(path)
      end

      def read_comments_from_file(file_path)
        return "No description available" unless file_path

        File.readlines(file_path)
            .drop_while { |line| line.include?("frozen_string_literal") || line.strip.empty? }
            .drop_while { |line| line.strip.start_with?("module") }
            .take_while { |line| line.strip.start_with?("#") }
            .join
            .strip
            .gsub(/^#\s*/, "")
      end
    end

    # rubocop:disable Lint/MissingSuper
    # DO NOT call super as we are deliberately decoupling the tool from the underlying library
    def initialize(params)
      @raw_params = params
      @params = coerce_and_validate!(params)
    end
    # rubocop:enable Lint/MissingSuper

    attr_reader :params

    private

    def coerce_and_validate!(input)
      coerced = {}
      self.class.defined_params.each do |key, config|
        value = input[key.to_s]
        raise ArgumentError, "Missing required parameter: #{key}" if config[:required] && value.nil?

        coerced[key] = Parameter.new(value, config[:type]).coerce!
      end
      coerced
    end
  end
end
