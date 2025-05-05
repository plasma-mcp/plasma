# frozen_string_literal: true

require_relative "test_helper"
require "stringio"

class TestCLI < Minitest::Test
  def setup
    @cli = Plasma::CLI.new
    @original_stdout = $stdout
    @original_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  def teardown
    $stdout = @original_stdout
    $stderr = @original_stderr
  end

  def test_plasma_project_detection
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        refute @cli.send(:plasma_project?)
        create_plasma_project_structure

        assert @cli.send(:plasma_project?)
      end
    end
  end

  def test_version_command
    @cli.version

    assert_equal "PLASMA version #{Plasma::VERSION}\n", $stdout.string
  end

  private

  def create_plasma_project_structure
    FileUtils.mkdir_p("config")
    FileUtils.mkdir_p("app/prompts")
    FileUtils.mkdir_p("app/resources")
    FileUtils.mkdir_p("app/tools")
    FileUtils.mkdir_p("app/variables")
    FileUtils.touch("config/application.rb")
    FileUtils.touch("config/boot.rb")
  end
end
