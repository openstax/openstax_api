module OpenStax
  module Api
    module DoorkeeperExtensions
      # Add some fields to Doorkeeper::Application
      def is_human?
        false
      end
      
      def is_application?
        true
      end
      
      def is_admin?
        false
      end
    end
  end
end

OpenStax::Api::Engine.config.after_initialize do
  Doorkeeper::Application.send :include, OpenStax::Api::DoorkeeperExtensions
end
