# frozen_string_literal: true

require "test_helper"

class TestParameter < Minitest::Test
  def setup
    @klass = Plasma::Parameter
  end

  def test_returns_nil_for_nil_value
    assert_nil @klass.new(nil, :any).coerce!
  end

  def test_coerces_integers
    assert_equal 42, @klass.new("42", :integer).coerce!
    assert_equal 0, @klass.new("0", :integer).coerce!
    assert_equal(-1, @klass.new("-1", :integer).coerce!)
  end

  def test_failed_integer_coercion
    assert_raises(ArgumentError) { @klass.new("3.14", :integer).coerce! }
    assert_raises(ArgumentError) { @klass.new("Wolf 359", :integer).coerce! }
  end

  def test_coerces_floats
    assert_in_delta(3.14, @klass.new("3.14", :float).coerce!)
    assert_in_delta(0.0, @klass.new("0", :float).coerce!)
    assert_in_delta(-1.5, @klass.new("-1.5", :float).coerce!)
  end

  def test_failed_float_coercion
    assert_raises(ArgumentError) { @klass.new("1.0f", :float).coerce! }
    assert_raises(ArgumentError) { @klass.new("NCC-1701", :float).coerce! }
  end

  def test_coerces_booleans # rubocop:disable Metrics/AbcSize
    assert @klass.new(true, :boolean).coerce!
    assert @klass.new("true", :boolean).coerce!
    assert @klass.new("TRUE", :boolean).coerce!
    refute @klass.new(false, :boolean).coerce!
    refute @klass.new("false", :boolean).coerce!
    refute @klass.new("FALSE", :boolean).coerce!
  end

  def test_coerces_strings
    assert_equal "Hello, World!", @klass.new("Hello, World!", :string).coerce!
    assert_equal "123", @klass.new(123, :string).coerce!
    assert_equal "[]", @klass.new([], :string).coerce!
  end

  def test_coerces_arrays
    assert_equal [1, 2, 3], @klass.new([1, 2, 3], :array).coerce!
    assert_equal %w[a b c], @klass.new('["a", "b", "c"]', :array).coerce!
    assert_equal [1, "two", 3.0], @klass.new("[1, \"two\", 3.0]", :array).coerce!
  end

  def test_failed_array_coercion
    assert_raises(ArgumentError) { @klass.new(:nonsense, :array).coerce! }
    assert_raises(ArgumentError) { @klass.new("[", :array).coerce! }
  end

  def test_unhandled_types_are_returned_as_is
    assert_equal :unhandled, @klass.new(:unhandled, :unhandled_type).coerce!
  end
end
