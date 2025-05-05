# frozen_string_literal: true

require_relative "test_helper"

class TestStorage < Minitest::Test
  def setup
    # Disconnect if we're connected
    ActiveRecord::Base.remove_connection if ActiveRecord::Base.connected?

    # Setup fresh database
    Plasma::Storage.setup
  end

  def teardown
    # Clean up after each test
    ActiveRecord::Base.remove_connection if ActiveRecord::Base.connected?
  end

  # rubocop:disable Metrics/AbcSize
  def test_add_and_find_records
    # Test adding a record
    record = Plasma::Storage.add_record(name: "Test Record", value: 42)

    assert_kind_of Plasma::Storage::Record, record
    assert_equal "Test Record", record.data["name"]
    assert_equal 42, record.data["value"]

    # Test finding all records
    records = Plasma::Storage.find_records

    assert_equal 1, records.length
    assert_equal "Test Record", records.first["name"]
    assert_equal 42, records.first["value"]
  end
  # rubocop:enable Metrics/AbcSize

  def test_find_records_by_field
    # Add test records
    Plasma::Storage.add_record(name: "Record 1", type: "test")
    Plasma::Storage.add_record(name: "Record 2", type: "test")
    Plasma::Storage.add_record(name: "Record 3", type: "other")

    # Test finding by field
    test_records = Plasma::Storage.find_records_by_field("type", "test")

    assert_equal 2, test_records.length

    assert(test_records.all? { |r| r["type"] == "test" })
  end

  def test_find_records_with_field
    # Add test records
    Plasma::Storage.add_record(name: "Record 1", type: "test")
    Plasma::Storage.add_record(name: "Record 2")
    Plasma::Storage.add_record(name: "Record 3", type: "other")

    # Test finding records with field
    records_with_type = Plasma::Storage.find_records_with_field("type")

    assert_equal 2, records_with_type.length
    assert(records_with_type.all? { |r| r["type"] })
  end

  def test_update_record_field
    # Add a record
    record = Plasma::Storage.add_record(name: "Original Name")

    # Update the name field
    Plasma::Storage.update_record_field(record.id, "name", "Updated Name")

    # Verify the update
    updated_record = Plasma::Storage.find_records.first

    assert_equal "Updated Name", updated_record["name"]
  end

  def test_variable_storage
    # Test setting a variable
    Plasma::Storage.set_var("test_key", "test_value")

    # Test getting the variable
    value = Plasma::Storage.get_var("test_key")

    assert_equal "test_value", value

    # Test setting a complex value
    complex_value = { nested: { data: [1, 2, 3] } }
    Plasma::Storage.set_var("complex_key", complex_value)

    # Test getting the complex value
    retrieved_value = Plasma::Storage.get_var("complex_key")

    assert_equal complex_value, retrieved_value
  end

  def test_dump_to_json
    # Add some test data
    Plasma::Storage.add_record(name: "Test Record")
    Plasma::Storage.set_var("test_var", "test_value")

    # Get the JSON dump
    json_data = JSON.parse(Plasma::Storage.dump_to_json)

    # Verify the structure
    assert json_data.key?("records")
    assert json_data.key?("variables")
    assert_equal 1, json_data["records"].length
    assert_equal "test_value", json_data["variables"]["test_var"]
  end
end
