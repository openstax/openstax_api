# A representer for Accounts
#
# This representer can be used directly or subclassed for an object that
# delegates username, first_name, last_name, full_name and title to an account

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
