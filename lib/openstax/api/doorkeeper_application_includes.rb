module OpenStax
  module Api
    module DoorkeeperApplicationIncludes
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

# This needs to run after the orm is selected in the doorkeeper initializer
OpenStax::Api::Engine.config.after_initialize do
  Doorkeeper::Application.send :include,
                               OpenStax::Api::DoorkeeperApplicationIncludes
end
