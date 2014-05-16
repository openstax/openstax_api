require 'openstax/api/engine'
require 'openstax/api/doorkeeper_application_includes'
require 'openstax/api/routing_mapper_includes'

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
      class Configuration
        attr_accessor :user_class_name
        attr_accessor :current_user_method
        
        def initialize      
          @user_class_name = 'User'
          @current_user_method = 'current_user'
        end
      end

  end
end
