require 'roar-rails'
require 'exception_notification'
require 'openstax/api/roar'
require 'openstax/api/apipie'

module OpenStax
  module Api
    module V1

      class ApiController < ::ApplicationController
        
        include ::Roar::Rails::ControllerAdditions
        include OpenStax::Api::Roar
        include OpenStax::Api::Apipie

        fine_print_skip_signatures(:general_terms_of_use,
                                   :privacy_policy) \
          if respond_to? :fine_print_skip_signatures

        skip_protect_beta if respond_to? :skip_protect_beta

        skip_before_filter :authenticate_user!
        doorkeeper_for :all, :unless => :user_without_token?
        skip_before_filter :verify_authenticity_token,
                           :unless => :user_without_token?

        respond_to :json
        rescue_from Exception, :with => :rescue_from_exception

        # Keep old current_user method so we can use it
        alias_method :current_human_user,
                     OpenStax::Api.configuration.current_user_method

        # TODO: doorkeeper users (or rather users who have doorkeeper
        # applications) need to agree to API terms of use (need to have agreed
        # to it at one time, can't require them to agree when terms change since
        # their apps are doing the talking) -- this needs more thought

        # TODO: maybe freak out if current_user is anonymous (require we know
        # who person/app is so we can do things like throttling, API terms
        # agreement, etc)

        # Always return an ApiUser
        def current_user
          @current_api_user ||= ApiUser.new(doorkeeper_token,
                                            lambda { current_human_user })
        end

      protected

        def user_without_token?
          current_human_user && doorkeeper_token.blank?
        end

        def rescue_from_exception(exception)
          # See https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L453 for error names/symbols
          error = :internal_server_error
          notify = true
      
          case exception
          when SecurityTransgression
            error = :forbidden
            notify = false
          when ActiveRecord::RecordNotFound, 
               ActionController::RoutingError,
               ActionController::UnknownController,
               AbstractController::ActionNotFound
            error = :not_found
            notify = false
          end

          if notify
            ExceptionNotifier.notify_exception(
              exception,
              env: request.env,
              data: { message: "An exception occurred" }
            )

            Rails.logger.error("An exception occurred: #{exception.message}\n\n#{exception.backtrace.join("\n")}") \
          end
          
          head error
        end

      end

    end
  end
end