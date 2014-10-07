require 'representable/json'

class UserSearchRepresenter < OpenStax::Api::V1::AbstractSearchRepresenter
  collection :items, inherit: true, class: User, decorator: UserRepresenter
end
