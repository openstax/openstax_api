require 'rails_helper'

module OpenStax
  module Api
    module V1
      describe Roar do
        let!(:controller) { OpenStax::Api::V1::ApiController.new }

        it 'adds methods to ApiController instance' do
          expect(controller).to respond_to(:standard_index)
          expect(controller).to respond_to(:standard_search)
          expect(controller).to respond_to(:standard_create)
          expect(controller).to respond_to(:standard_nested_create)
          expect(controller).to respond_to(:standard_read)
          expect(controller).to respond_to(:standard_update)
          expect(controller).to respond_to(:standard_destroy)
          expect(controller).to respond_to(:standard_restore)
          expect(controller).to respond_to(:standard_sort)
          expect(controller).to respond_to(:render_api_errors)
        end

        context 'render_api_errors' do
          it 'returns nil if errors is nil' do
            expect(controller).not_to receive(:render)
            expect(controller.render_api_errors(nil)).to be_nil
          end

          it 'returns nil if errors is empty' do
            expect(controller).not_to receive(:render)
            expect(controller.render_api_errors([])).to be_nil
            expect(controller.render_api_errors({})).to be_nil
          end

          it 'returns the rendered response if there are errors' do
            expect(controller).to receive(:render) do |options|
              expect(options[:json]).to eq({ status: 422, errors: [{code: :error}] })
              expect(options[:status]).to eq :unprocessable_entity
            end
            controller.render_api_errors(code: :error)
          end
        end
      end
    end
  end
end
