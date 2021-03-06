require 'rails_helper'

module OpenStax
  module Api
    describe RepresentableSchemaPrinter do
      it 'must print model schemas' do
        schema = RepresentableSchemaPrinter.json(UserRepresenter)
        expect(schema).to include('## Schema')
        expect(schema).to include('{#')
        expect(schema).to include(' .schema}')
        expect(schema).to include("<pre class='code'>")
        expect(schema).to include('</pre>')
        json_schema = schema.match(/<pre class='code'>([^<]*)<\/pre>/)
        expect(JSON.parse(json_schema[1])).to eq({
            "type" => "object",
            "required" => [ "username" ],
            "properties" => {
              "username" => { "type" => "string" },
              "name" => { "type" => "string" },
              "email" => { "type" => "string" }
            },
            "additionalProperties" => false
          })
      end
    end
  end
end
