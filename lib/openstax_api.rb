require 'openstax/api/engine'
require 'openstax/api/doorkeeper_extensions'
require 'openstax/api/route_extensions'

module OpenStax
  module Api

      def self.configure
        yield configuration
      end

      def self.configuration
        @configuration ||= Configuration.new
      end

      class Configuration
        attr_accessor :user_class_name
        
        def initialize      
          @user_class_name = 'User'
        end
      end

  end
end
