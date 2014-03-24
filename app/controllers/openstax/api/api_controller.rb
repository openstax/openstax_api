module OpenStax
  module Api
    class ApiController < ApplicationController           
      
      include Roar::Rails::ControllerAdditions

      skip_protect_beta if respond_to? :skip_protect_beta

      skip_before_filter :authenticate_user!

      fine_print_skip_signatures(:general_terms_of_use,
                                 :privacy_policy) \
        if respond_to? :fine_print_skip_signatures

      respond_to :json
      rescue_from Exception, :with => :rescue_from_exception

      def self.api_example(options={})
        return if Rails.env.test?
        raise IllegalArgument, "must supply a :url parameter" if !options[:url_base]

        url_base = options[:url_base].is_a?(Symbol) ?
                     UrlGenerator.new.send(options[:url_base], protocol: 'https') :
                     options[:url_base].to_s
        
        "#{url_base}/#{options[:url_end] || ''}"
      end

      def self.json_schema(representer, options={})
        RepresentableSchemaPrinter.json(representer, options)
      end
      
    protected

      def rescue_from_exception(exception)
        # See https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L453 for error names/symbols
        error = :internal_server_error
        notify = true
    
        case exception
        when SecurityTransgression
          error = :forbidden
          notify = false
        when ActiveRecord::RecordNotFound, 
             ActionController::RoutingError,
             ActionController::UnknownController,
             AbstractController::ActionNotFound
          error = :not_found
          notify = false
        end

        if notify
          ExceptionNotifier.notify_exception(
            exception,
            env: request.env,
            data: { message: "An exception occurred" }
          )

          Rails.logger.error("An exception occurred: #{exception.message}\n\n#{exception.backtrace.join("\n")}") \
        end
        
        head error
      end

    end

  end
end