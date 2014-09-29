module OpenStax
  module Api
    class Constraints
      cattr_accessor :main_app_name
      
      def initialize(options)
        @version = options[:version]
        @default = options[:default]
      end

      def api_accept_header
        self.main_app_name ||= OpenStax::Api::Engine::MAIN_APP_NAME.underscore
        "application/vnd.#{self.main_app_name}.openstax.#{@version.to_s}"
      end
      
      def matches?(req)
        !!(@default || req.headers['Accept'].try(:include?, api_accept_header))
      end
    end
  end
end
