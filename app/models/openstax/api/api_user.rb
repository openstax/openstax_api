# A "user" (lowercase 'u') of an API can take one of several forms.
# 
#   1. It can just be a User (capital 'U') based on session data (e.g. 
#      someone who logs into this site and then uses this site's Backbone 
#      interface).
#   2. It can be a combination of a Doorkeeper Application and a User, 
#      given via OAuth's Authorization or Implicit flows.
#   3. It can just be a Doorkeeper Application, given through OAuth's
#      Client Credentials flow.  
# 
# This API class gives us a way to abstract out these cases and also
# gives us accessors to get the Application and User objects, if available.

require 'openstax_utilities'

module OpenStax
  module Api
    class ApiUser

      USER_CLASS = OpenStax::Api.configuration.user_class_name.constantize

      def initialize(doorkeeper_token, non_doorkeeper_user_proc)
        @doorkeeper_token = doorkeeper_token
        @non_doorkeeper_user_proc = non_doorkeeper_user_proc
      end

      # Returns a Doorkeeper::Application or nil
      def application
        # If we have a doorkeeper_token, derive the Application from it.
        # If not, we're in case #1 above and the Application should be nil.
        @application ||= @doorkeeper_token.try(:application)
      end

      # Returns an instance of User, AnonymousUser, or nil
      def human_user
        # If we have a doorkeeper_token, derive the User from it.
        # If not, we're in case #1 above and the User should be
        # retrieved from the non_doorkeeper_user_proc.
        @user ||= @doorkeeper_token ? \
                    USER_CLASS.where(
                      :id => @doorkeeper_token.try(:resource_owner_id)
                    ).first : @non_doorkeeper_user_proc.call
      end

      ##########################
      # Access Control Helpers #
      ##########################

      def can_do?(action, resource)
        OSU::AccessPolicy.action_allowed?(action, self, resource)
      end

      def method_missing(method_name, *arguments, &block)
        if method_name.to_s =~ /\Acan_(\w+)\?\z/
          can_do?($1.to_sym, arguments.first)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s =~ /\Acan_(\w+)\?\z/ || super
      end

    end
  end
end
