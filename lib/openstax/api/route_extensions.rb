require 'openstax/api/constraints'

module OpenStax
  module Api
    module RouteExtensions
      def api(version, options = {})
        constraints = Constraints.new(version: version,
                                      default: options.delete(:default))
        namespace :api, defaults: {format: 'json'}.merge(options) do
          scope(module: version,
                constraints: constraints) { yield }
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, OpenStax::Api::RouteExtensions
