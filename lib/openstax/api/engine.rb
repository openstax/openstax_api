require 'doorkeeper'
require 'responders'
require 'roar-rails'
require 'exception_notification'
require 'openstax_utilities'
require 'openstax/api/roar'
require 'openstax/api/apipie'
require 'openstax/api/responder_with_put_and_patch_content'

module OpenStax
  module Api
    class Engine < ::Rails::Engine
      isolate_namespace OpenStax::Api

      config.generators do |g|
        g.test_framework      :rspec,        fixture: false
        g.fixture_replacement :factory_girl, dir: 'spec/factories'
        g.assets false
        g.helper false
      end
    end
  end
end
