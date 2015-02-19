require 'openstax_utilities'

module OpenStax
  module Api
    class Constraints
      def initialize(options)
        @version = options[:version]
        @default = options[:default]
      end

      def api_accept_header
        "application/vnd.openstax.#{@version.to_s}"
      end
      
      def matches?(req)
        !!(@default || req.headers['Accept'].try(:include?, api_accept_header))
      end
    end
  end
end
