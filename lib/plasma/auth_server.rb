# frozen_string_literal: true

require "omniauth"
require "sinatra/base"
require "rack/protection"

module Plasma
  # Handles OAuth authentication for PLASMA applications
  class AuthServer < Sinatra::Base
    use Rack::Session::Cookie, secret: ENV.fetch("SESSION_SECRET") { SecureRandom.hex(32) }
    use Rack::Protection::AuthenticityToken

    app = Plasma::Loader.load_project

    use OmniAuth::Builder do
      provider(*app.config.omniauth_provider_args)
    end

    def self.mark_ready_to_shutdown
      @ready_to_shutdown = true
    end

    def self.ready_to_shutdown?
      @ready_to_shutdown ||= false
    end

    get "/" do
      raise NotImplementedError, "This endpoint is not implemented, you must implement it in your auth_server.rb"
    end

    configure :development do
      set :show_exceptions, true
    end

    get "/callback" do
      token = request.env.dig("omniauth.auth", :credentials, :token)
      if token
        self.class.mark_ready_to_shutdown
        "token: #{token}"
      else
        "No token found, request.env: #{request.env.inspect}"
      end
    end
  end
end
