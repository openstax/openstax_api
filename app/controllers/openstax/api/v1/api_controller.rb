require 'roar-rails'
require 'exception_notification'
require 'openstax/api/roar'
require 'openstax/api/apipie'

module OpenStax
  module Api
    module V1

      class ApiController < ActionController::Base
  
        include ::Roar::Rails::ControllerAdditions
        include OpenStax::Api::Roar
        include OpenStax::Api::Apipie

        skip_protect_beta if respond_to? :skip_protect_beta

        skip_before_filter :authenticate_user!
        doorkeeper_for :all, :unless => :session_user?
        skip_before_filter :verify_authenticity_token,
                           :unless => :session_user?

        # This filter can wait until the user signs in again
        skip_interception :expired_password if respond_to? :skip_interception

        respond_to :json

        rescue_from Exception, :with => :rescue_from_exception

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

        # JSON can't really redirect
        # Redirect from a filter effectively means "deny access"
        def redirect_to(options = {}, response_status = {})
          head :forbidden
        end

        protected

        def session_user?
          current_human_user && doorkeeper_token.blank?
        end

        def rescue_from_exception(exception)
          # See https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L453 for error names/symbols
          error, notify = case exception
          when SecurityTransgression
            [:forbidden, false]
          when ActiveRecord::RecordNotFound, 
               ActionController::RoutingError,
               ActionController::UnknownController,
               AbstractController::ActionNotFound
            [:not_found, false]
          else
            [:internal_server_error, true]
          end

          if notify
            ExceptionNotifier.notify_exception(
              exception,
              env: request.env,
              data: { message: "An exception occurred" }
            )

            Rails.logger.error("An exception occurred: #{exception.message}\n\n#{exception.backtrace.join("\n")}")
          end

          raise exception if Rails.application.config.consider_all_requests_local
          head error
        end

      end

    end
  end
end