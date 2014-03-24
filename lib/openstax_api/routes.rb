require 'openstax_api/constraints'

module OpenStax
  module Api
    module Routes
      def api(version = :v1, default = false)
        constraints = Constraints.new(version: version, default: default)
        namespace :api, defaults: {format: 'json'} do
          scope(module: version,
                constraints: constraints) { yield }
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, OpenStax::Api::Routes
