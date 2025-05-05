# frozen_string_literal: true

require "active_record"
require "sqlite3"

# Load all models
Dir[File.join(__dir__, "storage", "*.rb")].each { |file| require file }

module Plasma
  # This module handles the storage operations for PLASMA applications
  module Storage
    # rubocop:disable Metrics/MethodLength
    def self.define_default_schema
      ActiveRecord::Schema.define(verbose: false) do
        create_table :records do |t|
          t.json :data
          t.timestamps
        end

        create_table :variables, id: false do |t|
          t.string :key, primary_key: true
          t.json :value
        end

        create_table :settings do |t|
          t.string :group, null: false
          t.json :data
          t.timestamps
        end

        add_index :settings, :group, unique: true
      end
    end
    # rubocop:enable Metrics/MethodLength

    def self.setup
      establish_connection
      load_schema
    end

    def self.establish_connection
      ActiveRecord::Base.establish_connection(
        adapter: "sqlite3",
        database: ":memory:"
      )
      ActiveRecord::Migration.verbose = false
    end

    def self.load_schema
      schema_path = File.join(Dir.pwd, "db", "schema.rb")
      if File.exist?(schema_path)
        load schema_path
      else
        define_default_schema
      end
    end

    def self.add_record(fields = {})
      Plasma::Storage::Record.create(data: fields)
    end

    def self.find_records
      Plasma::Storage::Record.all.map { |r| r.data.merge(id: r.id, created_at: r.created_at) }
    end

    def self.find_records_by_field(field, value)
      Plasma::Storage::Record.all.select { |r| r.data[field.to_s] == value || r.data[field.to_sym] == value }
                             .map { |r| r.data.merge(id: r.id, created_at: r.created_at) }
    end

    def self.find_records_with_field(field)
      records = Plasma::Storage::Record.all
      filtered = records.select { |r| r.data.key?(field.to_s) || r.data.key?(field.to_sym) }
      filtered.map { |r| r.data.merge(id: r.id, created_at: r.created_at) }
    end

    def self.update_record_field(id, field, value)
      record = Plasma::Storage::Record.find(id)
      record.data[field] = value
      record.save!
    end

    def self.set_var(key, value)
      Plasma::Storage::Variable.create_or_find_by(key: key).update(value: value)
    end

    def self.get_var(key)
      Plasma::Storage::Variable.find_by(key: key)&.value
    end

    def self.dump_to_json
      {
        records: find_records,
        variables: Plasma::Storage::Variable.all.pluck(:key, :value).to_h
      }.to_json
    end
  end
end

# Setup database when module is loaded
Plasma::Storage.setup
