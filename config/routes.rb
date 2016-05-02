OpenStax::Api::Engine.routes.draw do

  # respond to a CORS OPTIONS request.
  # The origin of the request is validated using the
  # configuration setting `validate_cors_origin`
  match "/*all" => 'v1/api#options',  via: [:options]

end
