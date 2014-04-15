OpenStax::Api.configure do |config|
  config.user_class_name = 'DummyUser'
  config.current_user_method = 'present_user'
end