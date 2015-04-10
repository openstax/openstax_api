module Api
  module V1

    class DummyController < OpenStax::Api::V1::ApiController

      def dummy
        head(:ok)
      end

    end

  end
end
