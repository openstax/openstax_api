require 'rails_helper'

module OpenStax
  module Api
    module V1
      describe Roar do
        let!(:controller) { OpenStax::Api::V1::ApiController.new }

        it 'adds methods to ApiController instance' do
          expect(controller).to respond_to(:standard_create)
          expect(controller).to respond_to(:standard_read)
          expect(controller).to respond_to(:standard_update)
          expect(controller).to respond_to(:standard_destroy)
          expect(controller).to respond_to(:standard_nested_create)
          expect(controller).to respond_to(:standard_index)
          expect(controller).to respond_to(:standard_search)
          expect(controller).to respond_to(:standard_sort)
        end
      end
    end
  end
end
