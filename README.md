# openstax_api

[![Gem Version](https://badge.fury.io/rb/openstax_api.svg)](http://badge.fury.io/rb/openstax_api)
[![Build Status](https://travis-ci.org/openstax/openstax_api.svg?branch=master)](https://travis-ci.org/openstax/openstax_api)
[![Code Climate](https://codeclimate.com/github/openstax/openstax_api/badges/gpa.svg)](https://codeclimate.com/github/openstax/openstax_api)

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

### Controller

`OpenStax::Api::V1::ApiController`

Your API controllers should inherit from ApiController.

Your `current_user` method will not be available in ApiController.
Instead, use the current_api_user, current_human_user and current_application methods.

### Model

`OpenStax::Api::V1::ApiUser`

Your users should NOT inherit from ApiUser. It is used only by ApiController.

ApiUser represents either a signed in user, a doorkeeper application, or a combination of both.

## Doorkeeper Extensions

This gem also adds the following methods to Doorkeeper::Application:

`is_human?`, `is_application?` and `is_admin?`

## Route simplification

Finally, this gem allows API routes to be simplified by using the api method, like so:

```rb
apipie

api :v1 do
  get '/your_api_v1_routes_go_here'
end

api :v2, default: true do
  get '/your_api_v2_routes_go_here'
end
```

The api route method takes a version argument and an options hash.
If the `:default` option is set to true, that version is the default (latest) and will always match the Accept header. It should be defined last, as any API route after that will be ignored.

## Testing

From the gem's main folder, run `bundle`, `rake db:migrate` and then `rake` to run all the specs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Create specs for your feature
4. Ensure that all specs pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new pull request

