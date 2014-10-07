# Represents search results for a JSON API
#
# Subclasses should define the representer for the search results:
#   collection :items, inherit: true, decorator: SomeRepresenter
#
# See ... for an example search representer

module OpenStax
  module Api
    module V1
      class AbstractSearchRepresenter < ::Roar::Decorator

        include ::Roar::Representer::JSON

        property :total_count,
                 type: Integer,
                 readable: true,
                 writeable: false,
                 schema_info: {
                   required: true,
                   description: "The number of items matching the query; can be more than the number returned if paginating"
                 }

        collection :items,
                   readable: true,
                   writeable: false,
                   schema_info: {
                     required: true,
                     description: "The items matching the query or a subset thereof when paginating"
                   }

      end
    end 
  end
end
