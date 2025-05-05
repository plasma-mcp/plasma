# frozen_string_literal: true

module Plasma
  module Storage
    # Base class for all application models
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
