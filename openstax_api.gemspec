$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'openstax/api/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'openstax_api'
  s.version     = OpenStax::Api::VERSION
  s.licenses    = ['MIT']
  s.authors     = ['Dante Soares', 'JP Slavinsky']
  s.email       = ['dms3@rice.edu', 'jps@kindlinglabs.com']
  s.homepage    = 'https://github.com/openstax/openstax_api'
  s.summary     = 'API utilities for OpenStax products and tools.'
  s.description = "Provides models, controllers and libraries that help OpenStax products define API's for user applications."

  s.files = Dir['{app,lib,config}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '>= 6', '<= 8'
  s.add_dependency 'addressable'
  s.add_dependency 'representable'
  s.add_dependency 'roar'
  s.add_dependency 'roar-rails', '>= 1'
  s.add_dependency 'uber'
  s.add_dependency 'doorkeeper'
  s.add_dependency 'exception_notification'
  s.add_dependency 'openstax_utilities'
  s.add_dependency 'lev', '>= 12.1.0'
  s.add_dependency 'responders'

  s.add_development_dependency 'listen'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'multi_json'
end
