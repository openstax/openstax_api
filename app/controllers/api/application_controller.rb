class ApplicationController < ::ApplicationController
  skip_before_filter :authenticate_user!

  layout :application_body_only
end
