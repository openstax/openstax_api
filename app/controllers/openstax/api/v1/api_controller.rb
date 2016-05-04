module OpenStax
  module Api
    module V1

      class ApiController < ActionController::Base

        include ::Roar::Rails::ControllerAdditions
        include OpenStax::Api::Roar
        include OpenStax::Api::Apipie

        protect_from_forgery with: :exception

        respond_to :json

        # after_filters are in place to make sure certain things are set how we
        # want even if something else goes on during the request.  These filters
        # are also paired with before_filters in case an exception prevents
        # normal action completion.

        # Always force JSON requests and send the Date header in the response
        before_filter :force_json_content_type
        before_filter :set_date_header
        after_filter :set_date_header

        # Doorkeeper is used only if a token is present
        # Access policies should be used to limit access to anonymous users
        before_filter :doorkeeper_authorize!, if: :token_user?

        # Except for users logged in via a cookie, we can disable CSRF protection and enable CORS
        skip_before_filter :verify_authenticity_token, unless: :local_session_user?
        skip_before_filter :authenticate_user!, only: :options
        skip_before_filter :verify_authenticity_token, only: :options

        before_filter  :maybe_set_cors_headers

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

        def options
          head :ok
        end

        protected

        # A session user who is not using CORS
        def local_session_user?
          session_user? && !request.headers.include?("HTTP_ORIGIN")
        end

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

        # Rails 3.x lacks response.date.  Remove `respond_to?` check after update
        def set_date_header
          response.date = Time.now if response.respond_to?(:date) and not response.date?
        end

        def maybe_set_cors_headers
          # only set headers if browser indicates it's using CORS by setting the ORIGIN
          return unless request.headers["HTTP_ORIGIN"]
          headers['Access-Control-Allow-Origin'] = validated_cors_origin
          headers['Access-Control-Allow-Credentials'] = 'true'
          headers['Access-Control-Allow-Methods'] = 'GET, HEAD, POST, PUT, PATCH, DELETE, OPTIONS'
          headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, X-CSRF-Token, Token, Authorization, Content-Type'
          headers['Access-Control-Max-Age'] = '86400'
        end

        def validated_cors_origin
          if OpenStax::Api.configuration.validate_cors_origin &&
             OpenStax::Api.configuration.validate_cors_origin[ request ]
            request.headers["HTTP_ORIGIN"]
          else
            '' # an empty string will disallow any access
          end
        end

      end

    end
  end
end
