# frozen_string_literal: true

require "test_helper"

class TestPlasma < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Plasma::VERSION
  end

  # rubocop:disable Minitest/UselessAssertion
  def test_it_does_something_useful
    assert true
  end
  # rubocop:enable Minitest/UselessAssertion
end
