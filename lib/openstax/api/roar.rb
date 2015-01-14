# Copyright 2011-2014 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'openstax_utilities'
require 'lev'

module OpenStax
  module Api

    module Roar

      def standard_search(model, routine, represent_with, options={})
        user = current_api_user
        OSU::AccessPolicy.require_action_allowed!(:search, user, model)
        result = routine.call(params)
        return render_api_errors(result.errors) if result.errors.any?
        outputs = result.outputs
        outputs[:items].each do |item|
          OSU::AccessPolicy.require_action_allowed!(:read, user, item)
        end
        respond_with outputs, represent_with: represent_with
      end

      def standard_create(model, represent_with=nil)
        model.class.transaction do
          consume!(model, represent_with: represent_with)
          yield model if block_given?
          OSU::AccessPolicy.require_action_allowed!(:create, current_api_user, model)

          if model.save
            respond_with model, represent_with: represent_with, status: :created
          else
            render_api_errors(model.errors)
          end
        end
      end

      def standard_read(model, represent_with=nil)
        OSU::AccessPolicy.require_action_allowed!(:read, current_api_user, model)
        respond_with model, represent_with: represent_with
      end

      def standard_update(model, represent_with=nil)
        # Must be able to update the record before and after the update itself
        OSU::AccessPolicy.require_action_allowed!(:update, current_api_user, model)

        model.class.transaction do
          consume!(model, represent_with: represent_with)
          yield model if block_given?
          OSU::AccessPolicy.require_action_allowed!(:update, current_api_user, model)
        
          if model.save
            head :no_content
          else
            render_api_errors(model.errors)
          end
        end
      end

      def standard_destroy(model)
        OSU::AccessPolicy.require_action_allowed!(:destroy, current_api_user, model)
        
        if model.destroy
          head :no_content
        else
          render_api_errors(model.errors)
        end
      end

      def standard_index(relation, represent_with)
        model_klass = relation.base_class
        OSU::AccessPolicy.require_action_allowed!(:index, current_api_user, model_klass)
        relation.each do |item|
          # Must be able to read each record
          OSU::AccessPolicy.require_action_allowed!(:read, current_api_user, item)
        end
        respond_with(Lev::Outputs.new(items: relation),
                     represent_with: represent_with)
      end

      def standard_sort(*args)
        raise NotYetImplemented
      end

      def standard_nested_create(model, container_association,
                                 container, represent_with=nil)
        # Must be able to update the container
        OSU::AccessPolicy.require_action_allowed!(:update, current_api_user, container)
        model.send("#{container_association.to_s}=", container)

        standard_create(model, represent_with)
      end

      def render_api_errors(errors, status = :unprocessable_entity)
        hash = {status: Rack::Utils.status_code(status)}
        case errors
        when ActiveModel::Errors, Lev::BetterActiveModelErrors
          hash[:errors] = []
          errors.each do |attribute, message|
            hash[:errors] << {code: "#{attribute.to_s}_#{
                               message.to_s.gsub(/[\s-]/, '_').gsub(/[^\w]/, '')
                             }", message: errors.full_message(attribute, message)}
          end
        when Lev::Errors
          hash[:errors] = errors.collect do |error|
            {code: error.code, message: error.message, data: error.data}
          end
        else
          hash[:errors] = [errors].flatten.collect do |error|
            {code: error.to_s}
          end
        end
        render json: hash, status: status
      end
      
    end

  end
end