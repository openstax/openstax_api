require 'spec_helper'

module OpenStax
  module Api
    describe Constraints do
      context 'default is not defined' do
        let!(:constraints) { Constraints.new(version: :v1) }
        let(:req) { double('Request') }

        it 'matches if version is correct in the accept headers' do
          req.stub(:headers).and_return({
            'Accept' => 'application/vnd.dummy.openstax.v1'
          })
          expect(constraints.matches? req).to be_true
        end

        it 'does not match if version is incorrect in the accept headers' do
          req.stub(:headers).and_return({
            'Accept' => 'application/vnd.dummy.openstax.v2'
          })
          expect(constraints.matches? req).to be_false
        end

        it 'does not match if version is not defined in the accept headers' do
          req.stub(:headers).and_return({
            'Accept' => '*/*',
          })
          expect(constraints.matches? req).to be_false
        end

        it 'does not match if accept is not in headers' do
          req.stub(:headers).and_return({
            'Host' => 'localhost'
          })
          expect(constraints.matches? req).to be_nil
        end
      end

      context 'default is defined' do
        let!(:default) { double('Default') }
        let!(:constraints) { Constraints.new(version: :v1, default: default) }
        let(:req) { double('Request') }

        it 'matches if version is correct in the accept headers' do
          req.stub(:headers).and_return({
            'Accept' => 'application/vnd.dummy.openstax.v1'
          })
          expect(constraints.matches? req).to be_true
        end

        it 'returns default if version is incorrect in the accept headers' do
          req.stub(:headers).and_return({
            'Accept' => 'application/vnd.dummy.openstax.v2'
          })
          expect(constraints.matches? req).to eq(default)
        end

        it 'returns default if version is not defined in the accept headers' do
          req.stub(:headers).and_return({
            'Accept' => '*/*',
          })
          expect(constraints.matches? req).to eq(default)
        end

        it 'returns default if accept is not in headers' do
          req.stub(:headers).and_return({
            'Host' => 'localhost'
          })
          expect(constraints.matches? req).to eq(default)
        end
      end
    end
  end
end
