# frozen_string_literal: true

require "model_context_protocol"

module Plasma
  # Base resource class for PLASMA applications
  class Resource < ModelContextProtocol::Server::Resource
    # Required by MCP - defines the resource schema
    # rubocop:disable Metrics/MethodLength
    def self.schema
      {
        name: name.underscore,
        description: "Base resource for PLASMA applications",
        content_schema: {
          type: "object",
          properties: {
            id: { type: "string" }
          },
          required: ["id"]
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    # Required by MCP - defines the resource content
    def content
      {
        id: id
      }
    end

    attr_reader :id

    def initialize(id:)
      @id = id
      super
    end
  end
end
