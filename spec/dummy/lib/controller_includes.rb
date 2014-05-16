module ControllerIncludes
  def present_user
    @user ||= DummyUser.create
  end
end

ActionController::Base.send :include, ControllerIncludes
