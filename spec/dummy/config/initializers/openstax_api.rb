OpenStax::Api.configure do |config|
  config.user_class_name = 'User'
  config.current_user_method = 'present_user'
end