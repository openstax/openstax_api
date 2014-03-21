require "openstax_api/engine"

module OpenstaxApi
  def main_app_name
    Rails.application.class.to_s.split("::").first
  end
end
