module OpenStax
  module Api
    module Params

      extend self

      def sign(params:, secret:, algorithm: 'sha256')
        local_params = params.merge(timestamp: Time.now.to_i)

        stringified_params = normalize(local_params)
        signature = OpenSSL::HMAC.hexdigest(algorithm, secret, stringified_params)

        local_params.merge!(signature: signature)
      end

      def signature_and_timestamp_valid?(params:, secret:, algorithm: 'sha256', timestamp_window_width: 2.minutes)
        local_params = params.dup
        incoming_signature = local_params.delete(:signature)

        return false if incoming_signature.blank?

        stringified_params = normalize(local_params)
        expected_signature = OpenSSL::HMAC.hexdigest(algorithm, secret, stringified_params)

        return false if expected_signature != incoming_signature

        timestamp_window = timestamp_window_width.ago..timestamp_window_width.from_now
        return false if !timestamp_window.cover?(Time.at(params[:timestamp].to_i))

        return true
      end

      # Below is borrowed from https://github.com/oauth-xx/oauth-ruby/blob/e397b3e2f540faaebd7912aeb2768835d151f795/lib/oauth/helper.rb
      # so we can call `normalize` on some params without adding dependence on full oauth gem

      RESERVED_CHARACTERS = /[^a-zA-Z0-9\-\.\_\~]/

      # Escape +value+ by URL encoding all non-reserved character.
      def escape(value)
        _escape(value.to_s.to_str)
      rescue ArgumentError
        _escape(value.to_s.to_str.force_encoding(Encoding::UTF_8))
      end

      def _escape(string)
        URI.escape(string, RESERVED_CHARACTERS)
      end

      # Normalize a +Hash+ of parameter values. Parameters are sorted by name, using lexicographical
      # byte value ordering. If two or more parameters share the same name, they are sorted by their value.
      # Parameters are concatenated in their sorted order into a single string. For each parameter, the name
      # is separated from the corresponding value by an "=" character, even if the value is empty. Each
      # name-value pair is separated by an "&" character.
      def normalize(params)
        params.sort.map do |k, values|
          if values.is_a?(Array)
            # make sure the array has an element so we don't lose the key
            values << nil if values.empty?
            # multiple values were provided for a single key
            values.sort.collect do |v|
              [escape(k),escape(v)] * "="
            end
          elsif values.is_a?(Hash)
            normalize_nested_query(values, k)
          else
            [escape(k),escape(values)] * "="
          end
        end * "&"
      end

      #Returns a string representation of the Hash like in URL query string
      # build_nested_query({:level_1 => {:level_2 => ['value_1','value_2']}}, 'prefix'))
      #   #=> ["prefix%5Blevel_1%5D%5Blevel_2%5D%5B%5D=value_1", "prefix%5Blevel_1%5D%5Blevel_2%5D%5B%5D=value_2"]
      def normalize_nested_query(value, prefix = nil)
        case value
        when Array
          value.map do |v|
            normalize_nested_query(v, "#{prefix}[]")
          end.flatten.sort
        when Hash
          value.map do |k, v|
            normalize_nested_query(v, prefix ? "#{prefix}[#{k}]" : k)
          end.flatten.sort
        else
          [escape(prefix), escape(value)] * "="
        end
      end

    end
  end
end
