module OpenStax
  module Api
    class Engine < ::Rails::Engine
      isolate_namespace OpenStax::Api

      config.after_initialize do
        MAIN_APP_NAME = ::Rails.application.class.parent_name
      end

      config.generators do |g|
        g.test_framework      :rspec,        :fixture => false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.assets false
        g.helper false
      end
    end
  end
end