# frozen_string_literal: true

require_relative "test_helper"
require "tempfile"
require "open3"
require "pathname"

# rubocop:disable Metrics/ClassLength
class TestServerInitialization < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir("plasma_test")
    @plasma_path = File.expand_path("../exe/plasma", __dir__)
    ENV["PLASMA_ENV"] = "test"
  end

  def teardown
    FileUtils.rm_rf(@temp_dir)
  end

  def test_server_initialization
    # Create new server
    output, status = Open3.capture2e("#{@plasma_path} new testserver", chdir: @temp_dir)

    assert_predicate status, :success?, "Failed to create new server: #{output}"

    server_dir = File.join(@temp_dir, "testserver")

    assert Dir.exist?(server_dir), "Server directory was not created"

    # Change to server directory
    Dir.chdir(server_dir) do
      setup_test_tool
      verify_server_initialization
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def setup_test_tool
    # Generate a test tool
    tool_command = "#{@plasma_path} g tool Calculator " \
                   "number1:float number2:float operation:string"
    output, status = Open3.capture2e(tool_command)

    assert_predicate status, :success?, "Failed to generate tool: #{output}"

    # Verify the tool was created
    tool_path = File.join("app", "tools", "calculator_tool.rb")

    assert_path_exists tool_path, "Tool file was not created"

    # Verify tool content
    tool_content = File.read(tool_path)

    # Check for key elements in the tool file, ignoring whitespace
    assert_includes tool_content.gsub(/\s+/, ""), "classCalculatorTool<Plasma::Tool"
    assert_includes tool_content.gsub(/\s+/, ""),
                    "param:number1,type:Float,description:\"Number1parameter\",required:true"
    assert_includes tool_content.gsub(/\s+/, ""),
                    "param:number2,type:Float,description:\"Number2parameter\",required:true"
    assert_includes tool_content.gsub(/\s+/, ""),
                    "param:operation,type:String,description:\"Operationparameter\",required:true"
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def verify_server_initialization
    # Start the server in a separate process
    stdin, stdout, stderr, wait_thr = Open3.popen3("#{@plasma_path} server")

    # Send initialization message
    init_message = {
      method: "initialize",
      params: {
        protocolVersion: "2024-11-05",
        capabilities: {},
        clientInfo: {
          name: "claude-ai",
          version: "0.1.0"
        }
      },
      jsonrpc: "2.0",
      id: 0
    }.to_json

    stdin.puts(init_message)
    stdin.close

    # Wait for response (with timeout)
    response = nil
    error_output = nil
    begin
      Timeout.timeout(5) do
        response = stdout.gets
        error_output = stderr.read
      end
    rescue Timeout::Error
      flunk "Server did not respond within timeout period"
    ensure
      Process.kill("TERM", wait_thr.pid)
      wait_thr.join
    end

    # Log any error output
    puts "Server error output: #{error_output}" if error_output && !error_output.empty?

    # Parse and validate response
    assert response, "No response received from server"
    parsed_response = JSON.parse(response)

    # Verify key fields in the response
    assert_equal "2.0", parsed_response["jsonrpc"]
    assert_equal 0, parsed_response["id"]

    result = parsed_response["result"]

    assert result, "Response missing result field"

    assert_equal "2024-11-05", result["protocolVersion"]
    assert_equal "Testserver MCP Server", result["serverInfo"]["name"]
    assert_equal "0.1.0", result["serverInfo"]["version"]

    capabilities = result["capabilities"]

    assert capabilities, "Response missing capabilities field"
    assert capabilities["tools"]["listChanged"], "tools.listChanged should be true"

    verify_tools_list
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def verify_tools_list
    # Send a tools/list request to get the actual tools
    list_message = {
      method: "tools/list",
      params: {},
      jsonrpc: "2.0",
      id: 1
    }.to_json

    stdin, stdout, _, wait_thr = Open3.popen3("#{@plasma_path} server")
    stdin.puts(list_message)
    stdin.close

    list_response = nil
    begin
      Timeout.timeout(5) do
        list_response = stdout.gets
      end
    rescue Timeout::Error
      flunk "Server did not respond to tools/list within timeout period"
    ensure
      Process.kill("TERM", wait_thr.pid)
      wait_thr.join
    end

    list_result = JSON.parse(list_response)["result"]

    assert list_result, "No tools list received"

    tools = list_result["tools"]

    assert tools, "Response missing tools list"
    assert_equal 1, tools.size, "Expected one tool to be registered"
    calculator = tools.first

    assert_equal "calculator", calculator["name"]
    assert_equal "A calculator tool", calculator["description"]
    assert_equal %w[number1 number2 operation], calculator["inputSchema"]["required"]
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
# rubocop:enable Metrics/ClassLength
