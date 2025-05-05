# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_globs = ["test/test_helper.rb", "test/**/*_test.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]
