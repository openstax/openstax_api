require 'rails_helper'

module OpenStax
  module Api
    module V1
      describe ApiController do

        let!(:user) { FactoryGirl.create :user }
        let!(:user_2) { FactoryGirl.create :user }
        let!(:application) { double('Doorkeeper::Application') }
        let!(:doorkeeper_token) { double('Doorkeeper::AccessToken') }
        let!(:non_doorkeeper_user_proc) { lambda { user } }
        let!(:controller) { ApiController.new }

        context 'no authentication' do
          before (:each) do
            controller.doorkeeper_token = nil
            controller.present_user = nil
          end
          
          it 'has no human_user and no application' do
            expect(controller.send :session_user?).to eq false
            expect(controller.current_application).to be_nil
            expect(controller.current_human_user).to be_nil
            expect(controller.current_session_user).to be_nil
          end
        end

        context 'session' do
          before (:each) do
            controller.doorkeeper_token = nil
            controller.present_user = user
          end
          
          it 'has a human_user but no application' do
            expect(controller.send :session_user?).to eq true
            expect(controller.current_application).to be_nil
            expect(controller.current_human_user).to eq user
            expect(controller.current_session_user).to eq user
          end
        end

        context 'token with application and human user' do
          before (:each) do
            controller.doorkeeper_token = doorkeeper_token
            controller.present_user = nil
          end
          
          it 'has a human_user from token and an application' do
            allow(doorkeeper_token).to receive(:application).and_return(application)
            allow(doorkeeper_token).to receive(:resource_owner_id).and_return(user.id)

            expect(controller.send :session_user?).to eq false
            expect(controller.current_application).to eq application
            expect(controller.current_human_user).to eq user
            expect(controller.current_session_user).to be_nil
          end
        end

        context 'token with application only' do
          before (:each) do
            controller.doorkeeper_token = doorkeeper_token
            controller.present_user = nil
          end
          
          it 'has an application but no human_user' do
            allow(doorkeeper_token).to receive(:application).and_return(application)
            allow(doorkeeper_token).to receive(:resource_owner_id).and_return(nil)

            expect(controller.send :session_user?).to eq false
            expect(controller.current_application).to eq application
            expect(controller.current_human_user).to eq nil
            expect(controller.current_session_user).to eq nil
          end
        end

        context 'session and token' do
          before (:each) do
            controller.doorkeeper_token = doorkeeper_token
            controller.present_user = user_2
          end

          it 'ignores the session unless explicitly asked' do
            allow(doorkeeper_token).to receive(:application).and_return(application)
            allow(doorkeeper_token).to receive(:resource_owner_id).and_return(user)

            expect(controller.send :session_user?).to eq false
            expect(controller.current_application).to eq application
            expect(controller.current_human_user).to eq user
            expect(controller.current_session_user).to eq user_2
          end
        end

      end
    end
  end
end
