module OpenStax
  module Api
    module V1
      class AbstractSearchRepresenter < ::Roar::Decorator

        class_attribute :klass, :representer

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
                   class: lambda { |*| klass },
                   decorator: lambda { |object, *| object.representer },
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
