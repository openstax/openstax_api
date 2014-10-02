require 'rails_helper'

module OpenStax
  module Api
    describe Constraints do
      context 'default is not defined' do
        let!(:constraints) { Constraints.new(version: :v1) }
        let(:req) { double('Request') }

        it 'matches if version is correct in the accept headers' do
          allow(req).to receive(:headers).and_return({
            'Accept' => 'application/vnd.openstax.dummy.v1'
          })
          expect(constraints.matches? req).to eq true
        end

        it 'does not match if version is incorrect in the accept headers' do
          allow(req).to receive(:headers).and_return({
            'Accept' => 'application/vnd.openstax.dummy.v2'
          })
          expect(constraints.matches? req).to eq false
        end

        it 'does not match if version is not defined in the accept headers' do
          allow(req).to receive(:headers).and_return({
            'Accept' => '*/*',
          })
          expect(constraints.matches? req).to eq false
        end

        it 'does not match if accept is not in headers' do
          allow(req).to receive(:headers).and_return({
            'Host' => 'localhost'
          })
          expect(constraints.matches? req).to eq false
        end
      end

      context 'default is defined' do
        let!(:constraints) { Constraints.new(version: :v1) }
        let!(:constraints_2) { Constraints.new(version: :v2, default: true) }
        let(:req) { double('Request') }

        it 'matches if version is correct in the accept headers or if default' do
          allow(req).to receive(:headers).and_return({
            'Accept' => 'application/vnd.openstax.dummy.v1'
          })
          expect(constraints.matches? req).to eq true
          expect(constraints_2.matches? req).to eq true

          allow(req).to receive(:headers).and_return({
            'Accept' => 'application/vnd.openstax.dummy.v2'
          })
          expect(constraints.matches? req).to eq false
          expect(constraints_2.matches? req).to eq true
        end

        it 'matches if version is invalid' do
          allow(req).to receive(:headers).and_return({
            'Accept' => 'application/vnd.openstax.dummy.v3'
          })
          expect(constraints.matches? req).to eq false
          expect(constraints_2.matches? req).to eq true
        end

        it 'matches if version is not defined in the accept headers' do
          allow(req).to receive(:headers).and_return({
            'Accept' => '*/*',
          })
          expect(constraints.matches? req).to eq false
          expect(constraints_2.matches? req).to eq true
        end

        it 'matches if accept is not in headers' do
          allow(req).to receive(:headers).and_return({
            'Host' => 'localhost'
          })
          expect(constraints.matches? req).to eq false
          expect(constraints_2.matches? req).to eq true
        end
      end
    end
  end
end
