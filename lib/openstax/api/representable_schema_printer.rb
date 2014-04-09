module OpenStax
  module Api
    class RepresentableSchemaPrinter

      def self.json(representer, options={})
        options[:include] ||= [:readable, :writeable]
        options[:indent] ||= '  '

        definitions = {}

        schema = json_schema(representer, definitions, options)
        schema[:definitions] = definitions

        json_string = JSON.pretty_generate(schema, {indent: options[:indent]})

        "\nSchema  {##{SecureRandom.hex(4)} .schema}\n------\n" +
        "<pre class='code'>\n#{json_string}\n</pre>\n"
      end

    protected

      def self.json_schema(representer, definitions, options={})
        schema = {
          # id: schema_id(representer),
          # title: schema_title(representer),
          type: "object",
          properties: {},
          required: []
          # :$schema => "http://json-schema.org/draft-04/schema#"
        }

        representer.representable_attrs.each do |attr|
          schema_info = attr.options[:schema_info] || {}

          schema[:required].push(attr.name) if schema_info[:required]

          next unless [options[:include]].flatten.any?{|inc| attr.send(inc.to_s+"?") || schema_info[:required]}
          
          attr_info = {}

          if attr.options[:collection]
            attr_info[:type] = "array"
          else
            attr_info[:type] = attr.options[:type].to_s.downcase if attr.options[:type]
          end

          schema_info.each do |key, value|
            next if [:required].include?(key)
            value = value.to_s.downcase if key == :type
            attr_info[key] = value
          end

          decorator = attr.options[:decorator].try(:is_a?, Proc) ? nil : attr.options[:decorator]

          if decorator
            relative_schema_id(decorator).tap do |id|
              attr_info[:$ref] = "#/definitions/#{id}"
              definitions[id] ||= json_schema(decorator, definitions, options)
            end
          end

          schema[:properties][attr.name.to_sym] = attr_info
        end

        schema
      end

      def self.schema_title(representer)
        representer.name.gsub(/Representer/,'')
      end

      def self.schema_id(representer)
        "http://#{OpenStax::Api::Engine::MAIN_APP_NAME.to_s}.openstax.org/" +
        "#{schema_title(representer).downcase.gsub(/::/,'/')}"
      end

      def self.relative_schema_id(representer)
        representer.name.gsub(/Representer/,'').downcase.gsub(/::/,'/')
      end

    end
  end
end
