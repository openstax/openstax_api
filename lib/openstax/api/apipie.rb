# Copyright 2011-2014 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'openstax/api/representable_schema_printer'

module OpenStax
  module Api

    module Apipie

      def self.included(base)
        base.send :extend, ClassMethods
      end

      module ClassMethods

        def api_example(options={})
          return if Rails.env.test?
          raise IllegalArgument, "must supply a :url parameter" if !options[:url_base]

          url_base = options[:url_base].is_a?(Symbol) ?
          UrlGenerator.new.send(options[:url_base], protocol: 'https') :
          options[:url_base].to_s

          "#{url_base}/#{options[:url_end] || ''}"
        end

        def json_schema(representer, options={})
          RepresentableSchemaPrinter.json(representer, options)
        end

        # A hack at a conversion from a Representer to a series of Apipie declarations
        # Can call it like any Apipie DSL method, 
        #
        #  example "blah"
        #  representer Api::V1::ExerciseRepresenter
        #  def update ...
        #
        def representer(representer)
          representer.representable_attrs.each do |attr|
            schema_info = attr.options[:schema_info] || {}
            param attr.name, (attr.options[:type] || Object), required: schema_info[:required]
          end
        end

      end

    end

  end
end