require 'rails_helper'

module OpenStax
  module Api
    module V1
      describe ApiController do

        let!(:user)                     { FactoryGirl.create :user }
        let!(:user_2)                   { FactoryGirl.create :user }
        let!(:application)              { double('Doorkeeper::Application') }
        let!(:doorkeeper_token)         { double('Doorkeeper::AccessToken') }
        let!(:non_doorkeeper_user_proc) { lambda { user } }
        let!(:controller)               { ApiController.new }
        let!(:dummy_controller)         {
          c = ::Api::V1::DummyController.new
          c.response = ActionDispatch::TestResponse.new
          c
        }

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

        context 'date' do
          before(:each) do
            instance_variable_set('@controller', dummy_controller)
          end

          it 'sets the Date header for successful API calls' do
            @controller.present_user = user
            get 'dummy'
            expect(Time.parse(response.headers['Date'])).to be_within(1.second).of(Time.now)
          end
        end

        context 'cors' do
          before(:each) do
            instance_variable_set('@controller', dummy_controller)
          end

          it 'sets the CORS headers for anonymous users' do
            get 'dummy'
            expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
            expect(response.headers['Access-Control-Allow-Credentials']).to be_nil
          end

          it 'sets the CORS headers for token users' do
            token = Doorkeeper::AccessToken.create!.token
            @request.headers['Authorization'] = "Bearer #{token}"
            get 'dummy'
            expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
            expect(response.headers['Access-Control-Allow-Credentials']).to be_nil
          end

          it 'sets the CORS headers for session users (the browser should block the request due to no Access-Control-Allow-Credentials header)' do
            @controller.present_user = user
            get 'dummy'
            expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
            expect(response.headers['Access-Control-Allow-Credentials']).to be_nil
          end
        end

      end
    end
  end
end
