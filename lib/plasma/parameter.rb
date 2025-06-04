# frozen_string_literal: true

module Plasma
  # This class handles type coercion and validation
  class Parameter
    def initialize(value, type)
      @value = value
      @type = type.to_s.downcase.to_sym
    end

    def call # rubocop:disable Metrics/MethodLength
      return if @value.nil?

      case @type
      when :integer
        cast_integer
      when :float
        cast_float
      when :boolean
        cast_boolean
      when :string
        cast_string
      when :array
        cast_array
      else
        @value
      end
    end

    alias coerce! call

    private

    def cast_boolean
      @value == true || @value.to_s.downcase == "true"
    end

    def cast_integer
      Integer(@value)
    rescue StandardError
      raise ArgumentError, "Invalid integer: #{@value}"
    end

    def cast_float
      Float(@value)
    rescue StandardError
      raise ArgumentError, "Invalid float: #{@value}"
    end

    def cast_string
      @value.to_s
    end

    def cast_array
      return @value if @value.is_a?(Array)

      raise ArgumentError, "Invalid array: #{@value}" unless @value.is_a?(String)

      begin
        parsed = JSON.parse(@value)
        raise ArgumentError, "Invalid array: #{@value}" unless parsed.is_a?(Array)

        parsed
      rescue JSON::ParserError
        raise ArgumentError, "Invalid array: #{@value}"
      end
    end
  end
end
