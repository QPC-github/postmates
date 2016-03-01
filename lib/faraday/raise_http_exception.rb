require 'json'
require 'faraday'
require_relative '../postmates/error'

module FaradayMiddleware
  class RaiseHTTPException < Faraday::Middleware
    def call(env)
      @app.call(env).on_complete do |response|
        parsed_response = JSON.parse(response.body)
        msg = parsed_response.is_a?(Array) ? response[:status] : "#{response[:status]} #{parsed_response['message']}"

        case response[:status]
        when 400 ; raise Postmates::BadRequest,          msg
        when 401 ; raise Postmates::Unauthorized,        msg
        when 403 ; raise Postmates::Forbidden,           msg
        when 404 ; raise Postmates::NotFound,            msg
        when 500 ; raise Postmates::InternalServerError, msg
        when 503 ; raise Postmates::ServiceUnavailable,  msg
        end
      end
    end

    def initialize(app)
      super app
      @parser = nil
    end
  end
end
