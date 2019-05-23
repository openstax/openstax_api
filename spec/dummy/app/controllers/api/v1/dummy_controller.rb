module Api
  module V1

    class DummyControllerError < StandardError; end

    class DummyController < OpenStax::Api::V1::ApiController

      rescue_from DummyControllerError do |e|
        head :internal_server_error
      end

      def dummy
        head :ok
      end

      def explode
        raise DummyControllerError, "kaboom"
      end

    end

  end
end
