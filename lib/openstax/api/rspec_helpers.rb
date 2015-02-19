# Provides API-specific HTTP request methods
#
# The args at the end of each request is interpreted a hash that can contain
# keys for:
#   :raw_post_data -- a JSON string (if a Hash provided, to_json will be called on it)
#   :parameters -- a hash of parameters
#   :session -- whatever built-in request methods expect
#   :flash -- whatever built-in request methods expect
#
# Helpful documentation:
#  https://github.com/rails/rails/blob/3-2-stable/actionpack/lib/action_controller/test_case.rb
#
module OpenStax
  module Api
    module RSpecHelpers

      def api_get(action, doorkeeper_token, args={})
        api_request(:get, action, doorkeeper_token, args)
      end

      def api_put(action, doorkeeper_token, args={})
        api_request(:put, action, doorkeeper_token, args)
      end

      def api_post(action, doorkeeper_token, args={})
        api_request(:post, action, doorkeeper_token, args)
      end

      def api_delete(action, doorkeeper_token, args={})
        api_request(:delete, action, doorkeeper_token, args)
      end

      def api_patch(action, doorkeeper_token, args={}) 
        api_request(:patch, action, doorkeeper_token, args)
      end

      def api_head(action, doorkeeper_token, args={})
        api_request(:head, action, doorkeeper_token, args)
      end

      def api_request(type, action, doorkeeper_token, args={})
        request_method = is_a_controller_spec? ?
                           :controller_spec_api_request : 
                           :request_spec_api_request
        self.send(request_method, type, action, doorkeeper_token, args)
      end

      private

      def controller_spec_api_request(type, action, doorkeeper_token, args={})
        raise IllegalArgument if ![:get, :post, :put, :delete, :patch, :head].include?(type)

        # Add the doorkeeper token info and the accept header

        request.env['HTTP_AUTHORIZATION'] = "Bearer #{doorkeeper_token.token}" \
          if doorkeeper_token

        request.env['HTTP_ACCEPT'] = http_accept_string

        # Set the raw post data in the request, converting to JSON if needed

        if args[:raw_post_data]
          request.env['RAW_POST_DATA'] = args[:raw_post_data].is_a?(Hash) ? 
                                         args[:raw_post_data].to_json : 
                                         args[:raw_post_data]
        end

        # Set the data format

        args[:parameters] ||= {}
        args[:parameters][:format] = 'json'

        # If these helpers are used from a request spec, action can
        # be a URL fragment string -- in such a case, prepend "/api"
        # to the front of the URL as a convenience to callers

        if action.is_a? String
          action = "/#{action}" if !action.starts_with?("/")
          action = "/api#{action}" if !action.starts_with?("/api/")
        end

        # Delegate the work to the normal HTTP request helpers
        self.send(type, action, args[:parameters], args[:session], args[:flash])
      end

      def request_spec_api_request(type, route, doorkeeper_token=nil, args={})
        http_header = {}
        http_header['HTTP_AUTHORIZATION'] = "Bearer #{doorkeeper_token.token}" if doorkeeper_token.present?
        http_header['HTTP_ACCEPT'] = http_accept_string

        send(type, route, {format: :json}, http_header)
      end

      def is_a_controller_spec?
        self.class.metadata[:type] == :controller
      end

      def http_accept_string
        # Select the version of the API based on the spec metadata and populate the vnd string
        version_string = self.class.metadata[:version].try(:to_s)
        raise ArgumentError, "Top-level 'describe' metadata must include a value for ':version'" if version_string.nil?
        "application/vnd.openstax.#{version_string}"
      end

    end
  end
end

if defined?(RSpec)
  RSpec.configure do |c|
    c.include OpenStax::Api::RSpecHelpers
  end
end
