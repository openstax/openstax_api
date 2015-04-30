# Represents search results for a JSON API
#
# Subclasses should define the representer for the search results:
#   collection :items, inherit: true, decorator: SomeRepresenter
#
# See spec/dummy/app/representers/user_search_representer.rb for an example search representer

module OpenStax
  module Api
    module V1
      class AbstractSearchRepresenter < ::Roar::Decorator

        include ::Roar::JSON

        property :total_count,
                 type: Integer,
                 readable: true,
                 writeable: false,
                 exec_context: :decorator,
                 schema_info: {
                   required: true,
                   description: "The number of items matching the query; can be more than the number returned if paginating"
                 }

        collection :items,
                   readable: true,
                   writeable: false,
                   exec_context: :decorator,
                   schema_info: {
                     required: true,
                     description: "The items matching the query or a subset thereof when paginating"
                   }

        def items
          return represented.items if represented.respond_to?(:items)
          return represented[:items] if represented.respond_to?(:has_key?) && \
                                        represented.has_key?(:items)
          represented
        end

        def total_count
          return represented.total_count if represented.respond_to?(:total_count)
          return represented[:total_count] if represented.respond_to?(:has_key?) && \
                                              represented.has_key?(:total_count)

          @items = items
          if @items.respond_to?(:length)
            if @items.respond_to?(:limit) && @items.respond_to?(:offset)
              @items.limit(nil).offset(nil).length
            else
              @items.length
            end
          else
            1
          end
        end

      end
    end 
  end
end
