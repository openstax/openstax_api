require 'representable/json'

module DummyUserRepresenter
  include Roar::Representer::JSON
  
  property :username, :schema_info => { :required => true }
  property :password_hash
end