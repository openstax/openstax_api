require 'openstax/api/constraints'

module OpenStax
  module Api
    module RoutingMapperIncludes
      def api(version, options = {})
        api_namespace = (options.delete(:namespace) || 'api').to_s
        routing_error_app = options.delete(:routing_error_app) || \
                              OpenStax::Api.configuration.routing_error_app
        constraints = Constraints.new(version: version, default: options.delete(:default))

        namespace api_namespace, defaults: {format: 'json'}.merge(options) do
          scope(except: [:new, :edit], module: version, constraints: constraints) do
            root to: '/apipie/apipies#index', defaults: {format: 'html', version: version.to_s}

            yield

            match '/*options', via: [:options], to: '/openstax/api/v1/api#options'
            match '/*other', via: [:all], to: routing_error_app
          end
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, OpenStax::Api::RoutingMapperIncludes
