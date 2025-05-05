# frozen_string_literal: true

require "model_context_protocol"

module Plasma
  # Base prompt class for PLASMA applications
  class Prompt < ModelContextProtocol::Server::Prompt
    # For now, this defers to the base class for everything
  end
end
