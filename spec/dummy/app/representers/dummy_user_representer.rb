require 'representable/json'

module DummyUserRepresenter
  include Roar::Representer::JSON
  
  property :username, :schema_info => { :required => true }
  property :name
  property :password_hash, readable: false, writeable: false
end