Rails.application.routes.draw do

  mount OpenstaxApi::Engine => "/openstax_api"
end
