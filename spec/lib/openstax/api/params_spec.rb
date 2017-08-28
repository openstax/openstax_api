require 'rails_helper'

module OpenStax
  module Api
    describe Params do

      let(:params) { {b: 1, a: 2} }
      let(:signed) { described_class.sign(params: params, secret: 'secret') }

      it 'signs and verifies' do
        expect(signed[:timestamp]).not_to be_blank
        expect(signed[:signature]).not_to be_blank

        expect(
          described_class.signature_and_timestamp_valid?(params: signed, secret: 'secret')
        ).to eq true
      end

      it 'does not verify is signature does not match' do
        signed[:signature] += "a"
        expect(
          described_class.signature_and_timestamp_valid?(params: signed, secret: 'secret')
        ).to eq false
      end

      it 'does not verify if signature blank' do
        signed[:signature] = " "
        expect(
          described_class.signature_and_timestamp_valid?(params: signed, secret: 'secret')
        ).to eq false
      end

      it 'does not verify if timestamp too long ago' do
        expect(
          described_class.signature_and_timestamp_valid?(params: signed,
                                                         secret: 'secret',
                                                         timestamp_window_width: 0.minutes)
        ).to eq false
      end

    end
  end
end
