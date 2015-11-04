require 'openstax/api/engine'
require 'openstax/api/doorkeeper_application_includes'
require 'openstax/api/routing_mapper_includes'
require 'openstax/api/rspec_helpers'

module OpenStax
  module Api

      def self.configure
        yield configuration
      end

      def self.configuration
        @configuration ||= Configuration.new
      end

      ###########################################################################
      #
      # Configuration machinery.
      #
      # To configure OpenStax Api, put the following code in your applications
      # initialization logic (eg. in the config/initializers in a Rails app)
      #
      #   OpenStax::Api.configure do |config|
      #     config.<parameter name> = <parameter value>
      #     ...
      #   end
      #
      # user_class_name is a String containing the name of your User model class.
      #
      # current_user_method is a String containing the name of your controller
      # method that returns the current user.
      #
      # routing_error_app is a Rack application that responds to routing errors for the API
      #
      # validate_cors_origin is a Proc that is called with the reqested origin for CORS requests.
      # The proc should return true/false to indicate the validity of the request's origin
      class Configuration
        attr_accessor :user_class_name
        attr_accessor :current_user_method
        attr_accessor :routing_error_app
        attr_accessor :validate_cors_origin

        def initialize
          @user_class_name = 'User'
          @current_user_method = 'current_user'
          @routing_error_app = lambda { |env|
            [404, {"Content-Type" => 'application/json'}, ['']] }
        end
      end

  end
end
