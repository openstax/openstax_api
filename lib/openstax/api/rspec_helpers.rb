# Provides API-specific HTTP request methods
#
# action is a symbol (controller specs) OR a relative url (request specs)
#
# doorkeeper_token is a Doorkeeper::AccessToken or nil
#
# args are a hash that can contain the following keys:
#   :params          -- a hash of parameters (controller specs) OR a json string (request specs)
#   :body            -- a JSON string (controller specs only)
#   :format          -- always set to :json for API calls
#   :session, :flash -- hashes (controller specs)
#   :headers, :env   -- hashes (request specs)
#
# Helpful documentation:
#  https://github.com/rails/rails/blob/3-2-stable/actionpack/lib/action_controller/test_case.rb
#
module OpenStax
  module Api
    module RSpecHelpers
      def api_get(action, doorkeeper_token = nil, args={})
        api_request(:get, action, doorkeeper_token, args)
      end

      def api_put(action, doorkeeper_token = nil, args={})
        api_request(:put, action, doorkeeper_token, args)
      end

      def api_post(action, doorkeeper_token = nil, args={})
        api_request(:post, action, doorkeeper_token, args)
      end

      def api_delete(action, doorkeeper_token = nil, args={})
        api_request(:delete, action, doorkeeper_token, args)
      end

      def api_patch(action, doorkeeper_token = nil, args={})
        api_request(:patch, action, doorkeeper_token, args)
      end

      def api_head(action, doorkeeper_token = nil, args={})
        api_request(:head, action, doorkeeper_token, args)
      end

      def api_request(type, action, doorkeeper_token = nil, args={})
        raise IllegalArgument unless [:head, :get, :post, :patch, :put, :delete].include?(type)

        headers = is_a_controller_spec? ? request.headers : {}

        # Select the version of the API based on the spec metadata and populate the accept header
        version_string = self.class.metadata[:version].try(:to_s)
        raise ArgumentError, "Top-level 'describe' metadata must include a value for ':version'" \
          if version_string.nil?
        headers['HTTP_ACCEPT'] = "application/vnd.openstax.#{version_string}"

        # Add the doorkeeper token header
        headers['HTTP_AUTHORIZATION'] = "Bearer #{doorkeeper_token.token}" \
          if doorkeeper_token

        headers['CONTENT_TYPE'] = 'application/json'

        if is_a_controller_spec?
          request.headers.merge! headers
          args[:format] = :json
          # Convert the request body to JSON if needed
          args[:body] = args[:body].to_json unless args[:body].nil? || args[:body].is_a?(String)
        else
          args[:headers] = headers
        end

        # If these helpers are used from a request spec, action can
        # be a URL fragment string -- in such a case, prepend "/api"
        # to the front of the URL as a convenience to callers

        action = action.to_s unless is_a_controller_spec?
        if action.is_a?(String) && !action.include?('://')
          action = "/#{action}" if !action.starts_with?('/')
          action = "/api#{action}" if !action.starts_with?('/api/')
        end

        send type, action, args
      end

      private

      def is_a_controller_spec?
        self.class.metadata[:type] == :controller
      end
    end
  end
end

# Add the helpers to RSpec but don't error out if the rspec gem is not present
begin
  require 'rspec/core'

  RSpec.configure do |c|
    c.include OpenStax::Api::RSpecHelpers
  end
rescue LoadError
end
