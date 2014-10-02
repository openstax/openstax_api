require 'rails_helper'

module OpenStax
  module Api
    describe DoorkeeperApplicationIncludes do
      it 'must add methods to Doorkeeper::Application' do
        application = Doorkeeper::Application.new
        expect(application).to respond_to(:is_human?)
        expect(application.is_human?).to eq(false)
        expect(application).to respond_to(:is_application?)
        expect(application.is_application?).to eq(true)
        expect(application).to respond_to(:is_admin?)
        expect(application.is_admin?).to eq(false)
      end
    end
  end
end
