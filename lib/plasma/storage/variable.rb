# frozen_string_literal: true

module Plasma
  module Storage
    # Model for storing key-value pairs with automatic JSON parsing
    class Variable < ApplicationRecord
      self.primary_key = "key"

      serialize :value do |val|
        case val
        when String
          begin
            JSON.parse(val)
          rescue JSON::ParserError
            val
          end
        when Hash, Array
          val
        else
          val.to_s
        end
      end

      class << self
        attr_accessor :default_value

        def inherited(subclass)
          super
          const_name = subclass.to_s.split("::").last
          Plasma.const_set(const_name, subclass) unless Plasma.const_defined?(const_name)
        end

        def key
          name.demodulize.underscore
        end

        def set(value)
          raise "Failed to set value for #{key}" unless create_or_find_by(key: key).update(value: value)

          value
        end

        def get
          find_by(key: key)&.value || default_value
        end

        def default(value)
          @default_value = value
        end
      end
    end
  end
end
