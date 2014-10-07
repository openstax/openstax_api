# Copyright 2011-2014 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'openstax_utilities'

module OpenStax
  module Api

    module Roar

      def standard_create(model, represent_with=nil, &block)
        standard_nested_create(model, nil, nil, represent_with, &block)
      end

      def standard_read(model, represent_with=nil)
        OSU::AccessPolicy.require_action_allowed!(:read, current_api_user, @model)
        respond_with model, represent_with: represent_with
      end

      def standard_update(model, represent_with=nil)
        OSU::AccessPolicy.require_action_allowed!(:update, current_api_user, model)

        model_klass.transaction do
          consume!(model, represent_with: represent_with)
          yield model if block_given?
          OSU::AccessPolicy.require_action_allowed!(:update, current_api_user, model)
        
          if model.save
            head :no_content
          else
            render json: model.errors, status: :unprocessable_entity
          end
        end
      end

      def standard_destroy(model)
        OSU::AccessPolicy.require_action_allowed!(:destroy, current_api_user, model)
        
        if model.destroy
          head :no_content
        else
          render json: model.errors, status: :unprocessable_entity
        end
      end

      def standard_nested_create(model, container_association=nil,
                                 container=nil, represent_with=nil)
        if container_association && container
          OSU::AccessPolicy.require_action_allowed!(:update, current_api_user, container)
          model.send("#{container_association.to_s}=", container)
        end

        # Unlike the implications of the representable README, "consume!" can
        # actually make changes to the database.  See http://goo.gl/WVLBqA. 
        # We do want to consume before checking the permissions so we can know
        # what we're dealing with, but if user doesn't have permission we don't
        # want to have changed the DB.  Wrap in a transaction to protect ourselves.
        model_klass.transaction do
          consume!(model, represent_with: represent_with)
          yield model if block_given?
          OSU::AccessPolicy.require_action_allowed!(:create, current_api_user, model)

          if model.save
            respond_with model, represent_with: represent_with, status: :created
          else
            render json: model.errors, status: :unprocessable_entity
          end
        end
      end

      def standard_index(relation, represent_with)
        model_klass = relation.base_class
        OSU::AccessPolicy.require_action_allowed!(:index, current_api_user, model_klass)
        respond_with relation, represent_with: represent_with
      end

      def standard_search(routine, query, options, represent_with)
        model_klass = routine.send(:initial_relation).base_class
        OSU::AccessPolicy.require_action_allowed!(:search, current_api_user, model_klass)
        outputs = routine.call(query, options).outputs
        respond_with outputs, represent_with: represent_with
      end

      def standard_sort(*args)
        raise NotYetImplemented
      end
      
    end

  end
end