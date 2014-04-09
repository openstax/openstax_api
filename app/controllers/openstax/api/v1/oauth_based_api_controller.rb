module OpenStax
  module Api
    module V1

      class OauthBasedApiController < ApiController

        def current_user
          @current_api_user ||= ApiUser.new(doorkeeper_token, lambda { super })
        end
           
      end

    end
  end
end
