# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "plasma"

require "minitest/autorun"

# Enable debug by default unless in production or test environment
require "debug" unless %w[production test].include?(ENV["PLASMA_ENV"])
