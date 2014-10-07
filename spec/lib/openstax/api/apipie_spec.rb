require 'rails_helper'

module OpenStax
  module Api
    module V1
      describe Apipie do
        it 'adds methods to ApiController class' do
          expect(OpenStax::Api::V1::ApiController).to respond_to(:api_example)
          expect(OpenStax::Api::V1::ApiController).to respond_to(:json_schema)
          expect(OpenStax::Api::V1::ApiController).to respond_to(:representer)
        end
      end
    end
  end
end
