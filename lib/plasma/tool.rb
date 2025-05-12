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
        module_name = to_s.split("::")[0..-2].join("::").constantize
        class_name = to_s.split("::").last.to_sym

        loader = ClassLoader.find_loader(module_name, class_name)
        return nil unless loader

        path = ClassLoader.get_path_from_loader(loader, module_name, class_name)
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

        coerced[key] = coerce_value(value, config[:type])
      end
      coerced
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    # This method is deliberately complex as it handles type coercion and validation
    def coerce_value(value, type)
      return if value.nil?

      case type.to_s.downcase.to_sym
      when :integer then begin
        Integer(value)
      rescue StandardError
        raise ArgumentError, "Invalid integer: #{value}"
      end
      when :float then begin
        Float(value)
      rescue StandardError
        raise ArgumentError, "Invalid float: #{value}"
      end
      when :boolean then !!(value == true || value.to_s.downcase == "true")
      when :string  then value.to_s
      when :array
        if value.is_a?(Array)
          value
        elsif value.is_a?(String)
          begin
            parsed = JSON.parse(value)
            raise ArgumentError, "Invalid array: #{value}" unless parsed.is_a?(Array)

            parsed
          rescue JSON::ParserError
            raise ArgumentError, "Invalid array: #{value}"
          end
        else
          raise ArgumentError, "Invalid array: #{value}"
        end
      else value
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  end
end
