require 'representable/json'

module UserRepresenter
  include Roar::Representer::JSON
  
  property :username
  property :password_hash
end