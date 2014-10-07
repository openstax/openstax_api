ActionController::Base.class_exec do
  attr_accessor :doorkeeper_token, :present_user
end
