module OpenStax
  module Api
    class RepresentableSchemaPrinter

      def self.json(representer, options={})
        options[:include] ||= [:readable, :writeable]

        schema = json_schema(representer, options)

        json_string = JSON.pretty_generate(schema)

        "\n## Schema  {##{SecureRandom.hex(4)} .schema}\n" +
        "\n<pre class='code'>\n#{json_string}\n</pre>\n"
      end

    protected

      def self.representer_name(representer)
        representer.name.chomp('Representer').underscore
      end

      def self.definition_name(name)
        "#/definitions/#{name}"
      end

      def self.json_object(representer, definitions, options = {})
        schema = { type: :object, required: [], properties: {},
                   additionalProperties: false }

        representer.representable_attrs.each do |attr|
          name = attr.name
          schema_info = attr[:schema_info] || {}

          schema[:required].push(name.to_sym) if schema_info[:required]

          # Skip unless attr includes the specified key or is required
          next unless [options[:include]].flatten.any?{ |inc|
                        attr.send(inc.to_s + "?")} || schema_info[:required]

          if attr[:use_decorator]
            # Implicit representer - nest attributes
            decorator = attr[:extend].evaluate(self)
            attr_info = json_object(decorator, definitions, options)
          else
            # Guess a default type based on the attribute name
            attr_info = { type: name.end_with?('id') ? :integer : :string }

            schema_info.each do |key, value|
              next if key == :required
              value = value.to_s.downcase if key == :type
              attr_info[key] = value
            end

            # Overwrite type for collections
            attr_info[:type] = :array if attr[:collection]

            if attr[:extend]
              # Explicit representer - use reference
              decorator = attr[:extend].evaluate(self)
              rname = representer_name(decorator)
              dname = definition_name(rname)

              if attr[:collection]
                attr_info[:items] = { :$ref => dname }
              else
                # Type is included in ref
                attr_info.delete(:type)
                attr_info[:$ref] = dname
              end

              definitions[rname] ||= json_object(decorator,
                                                 definitions, options)
            end

            schema[:properties][name.to_sym] = attr_info
          end
        end

        # Cleanup unused fields
        [:type, :required, :properties].each do |field|
          schema.delete(field) if schema[field].blank?
        end

        schema
      end

      def self.json_schema(representer, options = {})
        definitions = {}
        schema = json_object(representer, definitions, options)
        schema.delete(:additionalProperties)
        schema[:definitions] = definitions
        schema
      end

    end
  end
end
