module OpenStax
  module Api
    module V1

      class ApiController < ActionController::Base
  
        include ::Roar::Rails::ControllerAdditions
        include OpenStax::Api::Roar
        include OpenStax::Api::Apipie

        before_action :doorkeeper_authorize!, :unless => :session_user?
        skip_before_filter :verify_authenticity_token, :unless => :session_user?

        respond_to :json

        before_filter :force_json_content_type
        after_filter :set_date_header

        # Keep old current_user method so we can use it
        alias_method :current_session_user,
                     OpenStax::Api.configuration.current_user_method

        # Ensure we will never again confuse human users and api users
        undef_method OpenStax::Api.configuration.current_user_method

        # Always return an ApiUser
        def current_api_user
          @current_api_user ||= ApiUser.new(doorkeeper_token,
                                            lambda { current_session_user })
        end

        def current_application
          current_api_user.application
        end

        def current_human_user
          current_api_user.human_user
        end

        protected

        def session_user?
          !!current_session_user && doorkeeper_token.blank?
        end

        def set_date_header
          response.date = Time.now unless response.date?
        end

        def force_json_content_type
          # Force JSON content_type
          request.env['CONTENT_TYPE'] = 'application/json'
          request.env['action_dispatch.request.content_type'] = 'application/json'
        end

      end

    end
  end
end
