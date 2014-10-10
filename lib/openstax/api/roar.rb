# Copyright 2011-2014 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'openstax_utilities'

module OpenStax
  module Api

    module Roar

      def standard_search(routine, query, options, represent_with)
        model_klass = routine.search_class
        OSU::AccessPolicy.require_action_allowed!(:search, current_api_user, model_klass)
        outputs = routine.call(query, options).outputs
        outputs[:items].each do |item|
          OSU::AccessPolicy.require_action_allowed!(:read, current_api_user, item)
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
        respond_with({items: relation}, {represent_with: represent_with})
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
        h[:status] = status
        case errors
        when ActiveRecord::Errors
          h[:errors] = []
          errors.each_error do |attr, error|
            h[:errors] << {code: "#{attr.to_s}_#{error.type.to_s}",
                           message: error.full_message}
          end
        when Lev::Errors
          h[:errors] = errors.collect do |error|
            {code: error.code, message: error.message, data: error.data}
          end
        else
          h[:errors] = [errors].flatten.collect do |error|
            {code: error.to_s}
          end
        end
        render json: h, status: status
      end
      
    end

  end
end