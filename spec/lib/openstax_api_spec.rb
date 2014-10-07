require 'rails_helper'

describe OpenStax::Api do
  it 'is configurable' do
    expect(OpenStax::Api.configuration).to respond_to(:user_class_name)
    expect(OpenStax::Api.configuration).to respond_to(:current_user_method)
    expect(OpenStax::Api.configuration).to respond_to(:routing_error_app)

    expect(OpenStax::Api.configuration.user_class_name).to eq 'User'

    OpenStax::Api.configure { |config| config.user_class_name = 'Test' }

    expect(OpenStax::Api.configuration.user_class_name).to eq 'Test'

    OpenStax::Api.configure { |config| config.user_class_name = 'User' }

    expect(OpenStax::Api.configuration.user_class_name).to eq 'User'
  end
end
