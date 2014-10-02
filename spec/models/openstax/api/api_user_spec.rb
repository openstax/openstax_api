require 'rails_helper'

module OpenStax
  module Api
    describe ApiUser do
      let(:user) { DummyUser.create }
      let(:application) { double('Doorkeeper::Application') }
      let(:doorkeeper_token) { double('Doorkeeper::AccessToken') }
      let(:non_doorkeeper_user_proc) { lambda { user } }

      context 'human user' do
        let(:api_user) { ApiUser.new(nil, non_doorkeeper_user_proc) }
        
        it 'has a human_user but no application' do
          expect(api_user.application).to be_nil
          expect(api_user.human_user).to eq(user)
        end
      end

      context 'application with human user' do
        let(:api_user) { ApiUser.new(doorkeeper_token,
                                     non_doorkeeper_user_proc) }

        it 'has a human_user and an application' do
          allow(doorkeeper_token).to receive(:application).and_return(application)
          allow(doorkeeper_token).to receive(:resource_owner_id).and_return(user.id)

          expect(api_user.application).to eq(application)
          expect(api_user.human_user).to eq(user)
        end
      end

      context 'application only' do
        let(:api_user) { ApiUser.new(doorkeeper_token,
                                     non_doorkeeper_user_proc) }

        it 'has an application but no human_user' do
          allow(doorkeeper_token).to receive(:application).and_return(application)
          allow(doorkeeper_token).to receive(:resource_owner_id).and_return(nil)

          expect(api_user.application).to eq(application)
          expect(api_user.human_user).to be_nil
        end
      end
    end
  end
end
