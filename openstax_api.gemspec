$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'openstax_api/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'openstax_api'
  s.version     = OpenstaxApi::VERSION
  s.licenses    = ['MIT']
  s.authors     = ['Dante Soares']
  s.email       = ['dms3@rice.edu']
  s.homepage    = 'https://github.com/openstax/openstax_api'
  s.summary     = 'API utilities for OpenStax products and tools.'
  s.description = "Provides models, controllers and libraries that help OpenStax products define API's for user applications."

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 3.2'

  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'rspec-rails', '~> 2.14'
  s.add_development_dependency 'capybara', '~> 2.2'
  s.add_development_dependency 'factory_girl_rails', '~> 4.4'
end
