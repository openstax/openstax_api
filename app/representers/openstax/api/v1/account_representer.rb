module OpenStax
  module Api
    module V1
      class AccountRepresenter < Roar::Decorator

        include Roar::Representer::JSON

        property :username,
                 type: String,
                 readable: true,
                 writeable: false

        property :first_name,
                 type: String,
                 readable: true,
                 writeable: true

        property :last_name,
                 type: String,
                 readable: true,
                 writeable: true

        property :full_name,
                 type: String,
                 readable: true,
                 writeable: true

        property :title,
                 type: String,
                 readable: true,
                 writeable: true

      end
    end 
  end
end
