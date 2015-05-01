module OpenStax
  module Api
    module V1

      class ApiController < ActionController::Base
  
        include ::Roar::Rails::ControllerAdditions
        include OpenStax::Api::Roar
        include OpenStax::Api::Apipie

        respond_to :json

        # Always force JSON requests and send the Date header in the response
        before_filter :force_json_content_type
        after_filter :set_date_header

        # Doorkeeper is used and CSRF protection is disabled only if a token is present
        before_filter :doorkeeper_authorize!, if: :token_user?
        skip_before_filter :verify_authenticity_token, if: :token_user?

        # CORS is enabled unless the user is logged in via a cookie
        before_filter :set_cors_preflight_headers, unless: :session_user?
        after_filter :set_cors_headers, unless: :session_user?

        # Keep old current_user method so we can use it
        alias_method :current_session_user, OpenStax::Api.configuration.current_user_method

        # Ensure we will never again confuse human users and api users
        undef_method OpenStax::Api.configuration.current_user_method

        # Always return an ApiUser
        def current_api_user
          @current_api_user ||= ApiUser.new(doorkeeper_token, lambda { current_session_user })
        end

        def current_application
          current_api_user.application
        end

        def current_human_user
          current_api_user.human_user
        end

        protected

        def session_user?
          !current_session_user.nil? && \
          (!current_session_user.respond_to?(:is_anonymous?) || \
           !current_session_user.is_anonymous?) && \
          doorkeeper_token.nil?
        end

        def token_user?
          !doorkeeper_token.nil?
        end

        def force_json_content_type
          # Force JSON content_type
          request.env['CONTENT_TYPE'] = 'application/json'
          request.env['action_dispatch.request.content_type'] = 'application/json'
        end

        def set_date_header
          response.date = Time.now unless response.date?
        end

        def set_cors_preflight_headers
          if request.method == 'OPTIONS'
            headers['Access-Control-Allow-Origin'] = '*'
            headers['Access-Control-Allow-Methods'] = 'GET, HEAD, POST, PUT, PATCH, DELETE, OPTIONS'
            headers['Access-Control-Max-Age'] = '1728000'

            render :text => '', :content_type => 'text/plain'
          end
        end

        def set_cors_headers
          headers['Access-Control-Allow-Origin'] = '*'
        end

      end

    end
  end
end
