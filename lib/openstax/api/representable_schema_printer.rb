module OpenStax
  module Api
    class RepresentableSchemaPrinter

      def self.json_schema(representer, options = {})
        definitions = {}
        schema = json_object(representer, definitions, options)
        schema[:definitions] = definitions unless definitions.blank?
        schema
      end

      def self.json(representer, options={})
        options[:include] ||= [:readable, :writeable]

        schema = json_schema(representer, options)

        json_string = JSON.pretty_generate(schema)

        "\n## Schema  {##{SecureRandom.hex(4)} .schema}\n" +
        "\n<pre class='code'>\n#{json_string}\n</pre>\n"
      end

    protected

      def self.representer_name(representer)
        name = representer.name
        return nil if name.nil?
        name.chomp('Representer').demodulize.camelize(:lower)
      end

      def self.definition_name(name)
        "#/definitions/#{name}"
      end

      def self.json_object(representer, definitions, options = {})
        schema = { type: :object, required: [], properties: {},
                   additionalProperties: false }

        hierarchical_representers = []

        while (rr ||= representer) < ::Roar::Decorator
          hierarchical_representers.insert(0,rr)
          rr = rr.superclass
        end

        hierarchical_representers.each do |rr|
          rr.representable_attrs.each do |attr|
            name = attr[:as].evaluate(self)
            schema_info = attr[:schema_info] || {}

            schema[:required].push(name.to_sym) if schema_info[:required]

            # Skip unless attr includes the specified key or is required
            next unless [options[:include]].flatten.any?{ |inc|
              m = inc.to_s + "?"
              attr.respond_to?(m) ? attr.send(m) : attr[inc]
            } || schema_info[:required]

            # Guess a default type based on the attribute name
            type = attr[:type].to_s.downcase
            type = type.blank? ? \
                   (name.end_with?('id') ? :integer : :string) : type
            attr_info ||= { type: type }

            schema_info.each do |key, value|
              next if key == :required
              if key == :definitions
                definitions.merge!(value)
                next
              end
              value = value.to_s.downcase if key == :type
              attr_info[key] = value
            end

            # Overwrite type for collections
            attr_info[:type] = 'array' if attr[:collection]

            if attr[:extend]
              # We're dealing with a nested representer.  It may just be a simple representer 
              # or it could be an Uber::Callable (representing that the representer could be
              # one of a number of possible representers)

              if attr[:extend].is_a?(Uber::Options::Value) && attr[:extend].dynamic?
                # We're dealing with an Uber::Callable situation, so need to get the list of 
                # possible representers and add each one to the "oneOf" list as well as to
                # the definitions hash

                attr_info[:type] = 'object'
                attr_info[:oneOf] = []

                attr[:extend].evaluate(:all_sub_representers).each do |sub_representer|
                  srname = representer_name(sub_representer)
                  attr_info[:oneOf].push(:$ref => definition_name(srname))
                  definitions[srname] = json_object(sub_representer, definitions, options) if definitions[srname].nil?
                end
              else
                # We're dealing with a simple representer
                
                decorator = attr[:extend].evaluate(self)
                rname = representer_name(decorator)

                if rname
                  dname = definition_name(rname)

                  if attr[:collection]
                    attr_info[:items] = { :$ref => dname }
                  else
                    # Type is included in ref
                    attr_info.delete(:type)
                    attr_info[:$ref] = dname
                  end
                  if definitions[rname].nil?
                    definitions[rname] = {}
                    definitions[rname] = json_object(decorator,
                                                     definitions, options)
                  end
                else
                  attr_info.merge!(json_object(decorator, definitions, options))
                end
              end # .is_a?(...)

            end

            schema[:properties][name.to_sym] = attr_info

          end # rr.representer_attrs....
        end # hierarchical_representers...

        # Cleanup unused fields
        [:required, :properties].each do |field|
          schema.delete(field) if schema[field].blank?
        end

        schema
      end
    

    end
  end
end
