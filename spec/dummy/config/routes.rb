Rails.application.routes.draw do
  api :v1, :default => true do
    get 'dummy', controller: 'dummy'
  end
end
