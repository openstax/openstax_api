$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'openstax_api/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'openstax_api'
  s.version     = OpenstaxApi::VERSION
  s.licenses    = ['MIT']
  s.authors     = ['Dante Soares', 'JP Slavinsky']
  s.email       = ['dms3@rice.edu']
  s.homepage    = 'https://github.com/openstax/openstax_api'
  s.summary     = 'API utilities for OpenStax products and tools.'
  s.description = "Provides models, controllers and libraries that help OpenStax products define API's for user applications."

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 3.2'
  s.add_dependency 'roar', '~> 0.12'
  s.add_dependency 'roar-rails', '~> 0.1'
  s.add_dependency 'doorkeeper', '~> 0.6'
  s.add_dependency 'apipie-rails', '~> 0.1'
  s.add_dependency 'maruku', '~> 0.7'

  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'rspec-rails', '~> 2.14'
  s.add_development_dependency 'capybara', '~> 2.2'
  s.add_development_dependency 'factory_girl_rails', '~> 4.4'
end
