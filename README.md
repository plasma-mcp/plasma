# Plasma

[![Join our Discord](https://img.shields.io/discord/1338362937550573643?color=7289DA&label=Discord&logo=discord&logoColor=white)](https://discord.gg/B6NPUAgYmH)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/plasma-mcp/plasma/actions/workflows/main.yml/badge.svg)](https://github.com/plasma-mcp/plasma/actions/workflows/main.yml)

The **P**ractical **L**aunchpad **A**ssisting with **M**CP **A**bstraction.

![Plasma Logo](assets/ruby-plasma-mcp-300x300.png)

Plasma is a Ruby-based SDK that provides a Rails-inspired, convention-over-configuration approach to building Model Context Protocol servers. Like a plasma engine powering a spacecraft, Plasma provides the fundamental infrastructure to power your MCP services with minimal resistance.

> [🚀 Getting Started](#getting-started) • [📖 Usage Guide](#usage-guide) • [⚙️ Development](#development)

> ⚠️ **Warning**: Plasma is currently in pre-alpha development (0.0.1-pre). Until version 0.1.0 is released, all versions (including patch updates) may contain breaking changes. This allows us to rapidly iterate and improve the API based on early feedback. See our [roadmap](docs/ROADMAP.md) for more details.

## Features

- ✅ Rails-inspired project and component generation (tools, prompts, and resources)
- ✅ Storage system for persistent data (variables and records)
- 🚧 Local authentication system via Omniauth (coming soon - partially implemented)

## Getting Started

### Requirements

- Ruby `3.4` or higher (tested on `3.4.2+`)
- Bundler
- Docker (optional, for containerized deployment)

### Installation

Install Plasma:

```bash
gem install plasma-mcp
```

### Quick Start

1. Create a new project:
```bash
plasma new my_server
cd my_server
```

2. Generate your first tool:
```bash
plasma g tool greeting name:string
```


4. Start your plasma server (in STDIN/STDOUT mode)
```bash
plasma server
```

5. Pass it some JSON to try it out:
```json
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"greeting","arguments":{"name":"Jean-Luc Picard"}}}
```

You will get the output:
```json
{"jsonrpc":"2.0","id":1,"result":{"content":[{"type":"text","text":"Hello from GreetingTool with params: Jean-Luc Picard "}],"isError":false}}
```

Congratulations. We have liftoff! 🚀

## Usage Guide

### Project Structure
```
my_server/
├── app/
│   ├── prompts/        # MCP prompts
│   ├── resources/      # MCP resources
│   ├── tools/          # MCP tools
│   ├── variables/      # Per-session variables (e.g. `current_user_email_variable`)
│   └── records/        # Stored objects (e.g. `task_records`)
├── config/
│   ├── initializers/   # Preload configuration
│   ├── application.rb  # MCP server configuration
│   └── boot.rb         # Launch ignition sequence
└── .env                # Environment variables
```

### Creating Tools

Generate a new tool using the CLI:

```bash
plasma g tool greeting name:string
```

This will generate a tool file in `app/tools/greeting_tool.rb` that follows this structure:

```ruby
# app/tools/greeting_tool.rb
module MyServer
  module Tools
    # A friendly space station greeting system
    class GreetingTool < Plasma::Tool
      param :name,
            type: :string,
            description: "Name of the space traveler to welcome"

      def call
        respond_with(:text,
          text: <<~GREETING
            Welcome aboard, #{params[:name]}!
            Your presence has been registered in our stellar database. 🚀
          GREETING
        )
      end
    end
  end
end
```

The tool's description is automatically extracted from the comment above the class. Parameters are defined using the `param` class method, which supports:
- `type`: The parameter type (`:string`, `:number`, `:float`, `:boolean`, or `:array`)
- `description`: A description of the parameter
- `required`: Whether the parameter is required (defaults to false)

Parameters are accessed in the `call` method via the `params` hash.

The `respond_with` method supports several response types: `:text`, `:image`, `:resource` and `:error`

### Configuration

Configure your application in `config/application.rb`:

```ruby
module MyServer
  class Application < Plasma::Application
    self.initialize! do |config|
      config.name = "My Custom Server Name"
    end
  end
end
```

## Deployment

### Traditional `STDIN/STDOUT` Deployment

1. Set up your environment variables
2. Run the server:
```bash
plasma server
```

### Docker `STDIN/STDOUT` Deployment (coming soon)

Docker deployment support is currently under development. This feature will provide:
- Pre-built Docker images for easy deployment
- Containerized environment for consistent execution
- Integration with popular container orchestration platforms

Stay tuned for updates in our upcoming releases!

### SSE Deployment (coming soon)

Server-Sent Events (SSE) deployment is planned for version 0.2.0. This feature will include:
- Real-time event streaming capabilities
- WebSocket support for bidirectional communication
- Enhanced monitoring and debugging tools
- Improved error handling and recovery mechanisms

Stay tuned for updates in our upcoming releases!

## Development

### Getting Started with Development

After git cloning, run `bin/setup` to install dependencies. Then, run `rake test` to run the diagnostics. You can also run `bin/console` for a low level command terminal.

To start an interactive console for your project (similar to `rails console`):

```bash
plasma console
```

This will give you access to your project's environment where you can interact with your components, storage variables, and other features:

```ruby
# Example console session
> MyTool.new.call
=> "Tool execution result"
```

### Roadmap
For detailed information about our development status, versioning strategy, and roadmap, please see [ROADMAP.md](docs/ROADMAP.md).

## Community & Contributing

Join our Discord community to connect with other developers, get help, and stay updated on the latest developments:

[![Join our Discord](https://img.shields.io/discord/1338362937550573643?color=7289DA&label=Discord&logo=discord&logoColor=white)](https://discord.gg/B6NPUAgYmH)

## Contributing

Improvements and bug reports are welcome on GitHub at https://github.com/plasma-mcp/plasma

## License

This project is available as open source under the terms of the MIT License.
