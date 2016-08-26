# Copyright 2011-2014 Rice University. Licensed under the Affero General Public
# License version 3 or later.  See the COPYRIGHT file for details.

require 'openstax_utilities'
require 'lev'

module OpenStax
  module Api

    module Roar

      def standard_index(relation, represent_with, options={})
        model_klass = relation.base_class
        OSU::AccessPolicy.require_action_allowed!(:index, current_api_user, model_klass)

        represent_with_options = { user_options: options }.merge(represent_with: represent_with)

        relation.each do |item|
          # Must be able to read each record
          OSU::AccessPolicy.require_action_allowed!(:read, current_api_user, item)
        end

        respond_with(Lev::Outputs.new(items: relation), represent_with_options)
      end

      def standard_search(klass, routine, represent_with, options={})
        user = current_api_user
        OSU::AccessPolicy.require_action_allowed!(:search, user, klass)

        represent_with_options = { user_options: options }.merge(represent_with: represent_with)

        result = routine.call(params, options)
        return render_api_errors(result.errors) if result.errors.any?

        outputs = result.outputs
        outputs[:items].each do |item|
          OSU::AccessPolicy.require_action_allowed!(:read, user, item)
        end

        respond_with outputs, represent_with_options
      end

      def standard_create(model, represent_with=nil, options={})
        create_options = { status: :created, location: nil }
        represent_with_options = { user_options: options }.merge(represent_with: represent_with)

        model.class.transaction do
          consume!(model, represent_with_options.dup)
          yield model if block_given?
          OSU::AccessPolicy.require_action_allowed!(:create, current_api_user, model)

          if model.save
            respond_with model, create_options.merge(represent_with_options)
          else
            render_api_errors(model.errors)
          end
        end
      end

      def standard_nested_create(model, container_association, container,
                                 represent_with=nil, options={})
        # Must be able to update the container
        OSU::AccessPolicy.require_action_allowed!(:update, current_api_user, container)

        model.send("#{container_association.to_s}=", container)

        standard_create(model, represent_with, options)
      end

      def standard_read(model, represent_with=nil, use_timestamp_for_cache=false, options={})
        OSU::AccessPolicy.require_action_allowed!(:read, current_api_user, model)

        represent_with_options = { user_options: options }.merge(represent_with: represent_with)

        respond_with model, represent_with_options \
          if !use_timestamp_for_cache || stale?(model, template: false)
      end

      def standard_update(model, represent_with=nil, options={})
        # Must be able to update the record before and after the update itself
        OSU::AccessPolicy.require_action_allowed!(:update, current_api_user, model)

        responder_options = { responder: ResponderWithPutPatchDeleteContent }
        represent_with_options = { user_options: options }.merge(represent_with: represent_with)

        model.with_lock do
          consume!(model, represent_with_options.dup)
          yield model if block_given?
          OSU::AccessPolicy.require_action_allowed!(:update, current_api_user, model)

          if model.save
            # http://stackoverflow.com/a/27413178
            respond_with model, responder_options.merge(represent_with_options)
          else
            render_api_errors(model.errors)
          end
        end
      end

      def standard_destroy(model, represent_with=nil, options={})
        OSU::AccessPolicy.require_action_allowed!(:destroy, current_api_user, model)

        return render_api_errors(code: "#{model.model_name.element}_is_already_deleted",
                                 message: "#{model.model_name.human} is already deleted") \
          if model.respond_to?(:deleted?) && model.deleted?

        responder_options = { responder: ResponderWithPutPatchDeleteContent }
        represent_with_options = { user_options: options }.merge(represent_with: represent_with)

        model.with_lock do
          if model.destroy
            model.clear_association_cache
            respond_with model, responder_options.merge(represent_with_options)
          else
            render_api_errors(model.errors)
          end
        end
      end

      def standard_restore(model, represent_with=nil, options={})
        OSU::AccessPolicy.require_action_allowed!(:restore, current_api_user, model)

        return render_api_errors(code: "#{model.model_name.element}_is_not_deleted",
                                 message: "#{model.model_name.human} is not deleted") \
          if !model.respond_to?(:deleted?) || !model.deleted?

        recursive = options.has_key?(:recursive) ? options[:recursive] : true

        responder_options = { responder: ResponderWithPutPatchDeleteContent }
        represent_with_options = { user_options: options.except(:recursive) }
                                     .merge(represent_with: represent_with)

        model.with_lock do
          if model.restore(recursive: recursive)
            model.clear_association_cache
            respond_with model, responder_options.merge(represent_with_options)
          else
            render_api_errors(model.errors)
          end
        end
      end

      def standard_sort(*args)
        raise NotYetImplemented
      end

      def render_api_errors(errors, status = :unprocessable_entity)
        hash = { status: Rack::Utils.status_code(status) }

        case errors
        when ActiveModel::Errors, Lev::BetterActiveModelErrors
          hash[:errors] = errors.map do |attribute, message|
            {
              code: "#{attribute.to_s}_#{message.to_s.gsub(/[\s-]/, '_').gsub(/[^\w]/, '')}",
              message: errors.full_message(attribute, message)
            }
          end
        when Lev::Errors
          hash[:errors] = errors.map do |error|
            { code: error.code, message: error.message, data: error.data }
          end
        else
          hash[:errors] = [errors].flatten.map do |error|
            error.is_a?(Hash) ? error : { code: error.to_s.underscore,
                                          message: error.to_s.humanize }
          end
        end

        render json: hash, status: status
      end

    end

  end
end
