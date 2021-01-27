Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  api :v1, default: true do
    get 'dummy', controller: 'dummy'
    get 'explode', controller: 'dummy'
  end
end
