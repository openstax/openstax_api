require 'spec_helper'

module OpenStax
  module Api
    module V1
      describe RepresentableSchemaPrinter do
        it 'must print model schemas' do
          schema = RepresentableSchemaPrinter.json(UserRepresenter)
          expect(schema).to include('Schema')
          expect(schema).to include('.schema')
          expect(schema).to include('------')
          expect(schema).to include("<pre class='code'>")
          expect(schema).to include("{\n  \"type\": \"object\",\n  \"properties\": {\n    \"username\": {\n    },\n    \"password_hash\": {\n    }\n  },\n  \"required\": [\n\n  ],\n  \"definitions\": {\n  }\n}")
          expect(schema).to include('</pre>')
        end
      end
    end
  end
end
