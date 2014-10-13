require 'rails_helper'

module OpenStax
  module Api
    describe RoutingMapperIncludes do
      it 'must add api method to ActionDispatch::Routing::Mapper' do
        mapper = ActionDispatch::Routing::Mapper.new(Rails.application.routes)
        expect(mapper).to respond_to(:api)
        Rails.application.routes.draw do
          api :v1 do
            resource :dummy_models
          end
        end
        route_names = Rails.application.routes.named_routes.names
        expect(route_names).to include(:api)
        expect(route_names).to include(:api_dummy_models)
      end
    end
  end
end
