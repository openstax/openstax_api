class ApplicationController < ActionController::Base
  protect_from_forgery

  def present_user
    @user ||= DummyUser.create
  end
end
