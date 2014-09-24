require 'openstax/api/constraints'

module OpenStax
  module Api
    module RoutingMapperIncludes
      def api(version, options = {})
        api_namespace = (options.delete(:namespace) || 'api').to_s
        constraints = Constraints.new(version: version,
                                      default: options.delete(:default))

        namespace api_namespace, defaults: {format: 'json'}.merge(options) do
          scope(module: version,
                constraints: constraints) do
            get '/', to: '/apipie/apipies#index', defaults: {format: 'html',
                                                             version: version.to_s}

            yield

            match '/*other', via: [:get, :post, :put, :patch, :delete],
                  to: lambda { |env| [404, {"Content-Type" => 'application/json'}, ['']] }
          end
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include,
                                     OpenStax::Api::RoutingMapperIncludes
