require 'representable/json'

module DummyUserRepresenter
  include Roar::Representer::JSON
  
  property :username
  property :password_hash
end