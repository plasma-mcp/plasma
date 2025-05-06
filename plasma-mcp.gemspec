# frozen_string_literal: true

require_relative "lib/plasma/version"

Gem::Specification.new do |spec|
  spec.name = "plasma-mcp"
  spec.version = Plasma::VERSION
  spec.authors = ["Jacob Foster Heimark"]
  spec.email = ["hmk@users.noreply.github.com"]
  spec.license = "MIT"

  spec.summary = "Rails-inspired framework for building Model Context Protocol (MCP) servers"
  spec.description = "Plasma is a Ruby-based SDK that provides a Rails-inspired, " \
                     "convention-over-configuration approach to building " \
                     "Model Context Protocol servers."
  spec.homepage = "https://github.com/plasma-mcp/plasma"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/plasma-mcp/plasma"
  spec.metadata["changelog_uri"] = "https://github.com/plasma-mcp/plasma/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    files = ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github Gemfile assets/])
    end
    files
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activerecord", "~> 8.0.2"
  spec.add_dependency "activesupport", "~> 8.0.2"
  spec.add_dependency "dotenv", "~> 2.8"
  spec.add_dependency "json", "~> 2.7.1"
  spec.add_dependency "model-context-protocol-rb", "~> 0.3.1"
  spec.add_dependency "omniauth", "~> 2.1.3"
  spec.add_dependency "puma", "~> 6.3.0"
  spec.add_dependency "rack", "~> 3.1.13"
  spec.add_dependency "sinatra", "~> 4.1.1"
  spec.add_dependency "sqlite3", "~> 2.6.0"
  spec.add_dependency "thor", "~> 1.3.2"
  spec.add_dependency "zeitwerk", "~> 2.7.2"
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
