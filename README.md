# openstax_api

API utilities for OpenStax products and tools.

## Installation

Add this line to your application's Gemfile:

```rb
gem 'openstax_api'
```

And then execute:

```sh
$ bundle
```

## Included classes

This gem includes the following classes, all under the OpenStax::Api namespace:

### Controllers

`ApiController`

`OauthBasedApiController`

Your API controllers should inherit from those classes.

### Models

`ApiUser`

This is the class of someone using the API, which can either be a (signed in) user, a doorkeeper application, or a combination of both.

## Doorkeeper Extensions

This gem also adds the following methods to Doorkeeper::Application:

`is_human?`, `is_application?` and `is_admin?`

## Route simplification

Finally, this gem allows API routes to be simplified by using the api method, like so:

```rb
apipie

get 'api', to: 'static_pages#api'

api :v1, true do
  get '/your_api_routes_go_here'
end
```

The api route method takes a version argument and a boolean.
If the boolean is true, that version is the default (latest) and will always match the Accept header. It should be defined last, as any API route after that will be ignored.

## Testing

From the gem's main folder, run `bundle`, and then `rake` to run all the specs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Create specs for your feature
4. Ensure that all specs pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new pull request

