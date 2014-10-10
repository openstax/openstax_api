module OpenStax
  module Api
    class RepresentableSchemaPrinter

      # Returns the json schema for a representer
      def self.json_schema(representer, options = {})
        definitions = {}
        schema = json_object(representer, definitions, options)
        schema[:definitions] = definitions unless definitions.blank?
        schema
      end

      # Returns some formatted Markdown with HTML containing the
      # JSON schema for a given representer
      def self.json(representer, options={})
        options[:include] ||= [:readable, :writeable]

        schema = json_schema(representer, options)

        json_string = JSON.pretty_generate(schema)

        "\n## Schema  {##{SecureRandom.hex(4)} .schema}\n" +
        "\n<pre class='code'>\n#{json_string}\n</pre>\n"
      end

      protected

      # Attempts to extract the given representer's name
      def self.representer_name(representer)
        name = representer.try :name
        return nil if name.nil?
        name.chomp('Representer').demodulize.camelize(:lower)
      end

      # Gets the definition name for the given representer name
      def self.definition_name(name)
        "#/definitions/#{name}"
      end

      # Helper function for json_schema
      def self.json_object(representer, definitions, options = {})
        # Initialize the schema
        schema = { type: :object, required: [], properties: {},
                   additionalProperties: false }

        representer.representable_attrs.each do |attr|
          # Handle some common attributes (as, schema_info, required)
          name = attr[:as].evaluate(representer)
          schema_info = attr[:schema_info] || {}

          schema[:required].push(name.to_sym) if schema_info[:required]

          # Skip attr it attr includes the specified key or is "required"
          next unless [options[:include]].flatten.any?{ |inc|
            m = inc.to_s + "?"
            attr.respond_to?(m) ? attr.send(m) : attr[inc]
          } || schema_info[:required]

          # Guess a default type based on the attribute name
          type = attr[:type].to_s.downcase
          type = type.blank? ? \
                 (name.end_with?('id') ? :integer : :string) : type
          attr_info ||= { type: type }

          # Process the schema_info attribute
          schema_info.each do |key, value|
            # Handle special keys (required, definitions, type)
            next if key == :required
            if key == :definitions
              definitions.merge!(value)
              next
            end
            value = value.to_s.downcase if key == :type
            # Store the schema_info k-v pair in attr_info
            attr_info[key] = value
          end

          # Overwrite type for collections
          attr_info[:type] = 'array' if attr[:collection]

          # Handle nested representers
          if attr[:extend]
            # The nested representer can be either a simple representer or
            # an Uber::Callable, in which case there could be multiple representers

            # Get the nested representers
            # Evaluate syntax is evaluate(context, instance or class, *args)
            # We have no instance or class (since we have no fragment), so we pass nil
            # By convention, the callables we use should return an array of all
            # possible representers when we pass the :all_sub_representers => true option
            klass = attr[:class].evaluate(representer, '') rescue Object
            decorators = [attr[:extend].evaluate(representer, klass, :all_sub_representers => true)].flatten.compact rescue []

            # Count the representers
            include_oneof = decorators.length > 1
            # If we have more than one possible representer, use oneOf to list them all
            sreps = include_oneof ? { oneOf: [] } : {}

            decorators.each do |decorator|
              # Attempt to get the representer's name
              rname = representer_name(decorator)

              if rname
                # We have a representer name, so use a schema definition with that name
                dname = definition_name(rname)
                dhash = { :$ref => dname }

                include_oneof ? sreps[:oneOf].push(dhash) : sreps = dhash

                if definitions[rname].nil?
                  # No definition with that name found, so add it
                  # A blank definition is added first to prevent infinite loops
                  definitions[rname] = {}
                  definitions[rname] = json_object(decorator, definitions, options)
                end
              else
                # No representer name, so add the object inline instead
                obj = json_object(decorator, definitions, options)
                include_oneof ? sreps[:oneOf].push(obj) : sreps = obj
              end
            end

            if attr[:collection]
              # Collection
              #   Type already set above (array)
              #   Add sub representers under :items
              attr_info[:items] = sreps
            else
              # Not a collection
              #   Type included in ref
              #   Add sub representers inline
              attr_info.delete(:type)
              attr_info.merge!(sreps)
            end

          end

          # Merge attr_info back into the schema
          schema[:properties][name.to_sym] = attr_info
        end

        # Cleanup unused fields
        [:required, :properties].each do |field|
          schema.delete(field) if schema[field].blank?
        end

        # Return the completed object schema
        schema
      end

    end
  end
end
