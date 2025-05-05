# Plasma Development Roadmap

## Versioning Strategy

**Until version 0.1.0 is released, all versions (including patch updates) may contain breaking changes.** This allows us to rapidly iterate and improve the API based on early feedback. After version 0.1.0, we will strictly follow semantic versioning:

- **Major version** (1.0.0, 2.0.0): Breaking changes
- **Minor version** (1.1.0, 1.2.0): New features, no breaking changes
- **Patch version** (1.0.1, 1.0.2): Bug fixes and minor improvements, no breaking changes

## Current Status

Plasma is currently in alpha development (0.0.x). The project is actively being developed with the following planned milestones:

- Version 0.0.1: Initial alpha release with basic functionality
- Version 0.1.0: Beta release with core features
- Version 0.2.0: First stable release

## Development Focus

### 0.1 Development Focus

- [x] Storage system for persistent data
- [x] Component generation for prompts, resources, and tools
- [x] Improved tool response mechanics (i.e. `respond_with`-ish rails pattern on response)
- [x] Improved tool ergonomics with type hints and Ruby magic
- [x] Draft authentication system implementation
- [x] Docker file template as part of new generation (and commands to upload)
- [x] Including docker usage in readme
- [x] First pass at authentication system with Sinatra
- [ ] Reference servers with example usage
- [ ] Gem & executable as part of new generation
- [ ] CLI command to get json for Claude (docker and gem versions)

### 0.2 Development Focus
- Complete authentication system implementation
- Update to include features from latest MCP version (`2025-03-27`)
- Server-Sent Events (SSE) support for real-time updates
- Enhanced OAuth integration with latest MCP authentication patterns
- Improved error handling and recovery mechanisms
- Performance optimizations for high-concurrency scenarios
- Generate rspec tests and test framework on `plasma new`
- Migrate to rspec for plasma-mcp itself
- Expand test coverage and CI/CD pipeline improvements
- Testing framework improvements with helper methods and fixtures for common MCP patterns
- Wiki / improved documentation