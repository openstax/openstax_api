require 'representable/json'

class UserRepresenter < ::Roar::Decorator

  include Roar::Representer::JSON
  
  property :username, readable: false, writeable: false,
                      schema_info: { required: true }
  property :name, readable: true, writeable: true
  property :email, readable: false, writeable: true
  property :password_hash, readable: false, writeable: false

end
