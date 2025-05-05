# frozen_string_literal: true

module Plasma
  module Storage
    # Model for storing serialized data with automatic JSON parsing
    class Record < ApplicationRecord
      class << self
        def inherited(subclass)
          super
          const_name = subclass.to_s.split("::").last
          Plasma.const_set(const_name, subclass) unless Plasma.const_defined?(const_name)
        end
      end
    end
  end
end
