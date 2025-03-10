# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveCall::Base do
  describe '.call' do
    context 'when validations pass' do
      let(:service_class) do
        Class.new(ActiveCall::Base) do
          attr_accessor :input

          def initialize(input)
            @input = input
          end

          def call
            "Processed: #{input}"
          end
        end
      end

      before do
        stub_const('TestService', service_class)
      end

      it 'returns a service instance' do
        result = TestService.call('test')
        expect(result).to be_an_instance_of(TestService)
      end

      it 'sets the response from the call method' do
        result = TestService.call('test')
        expect(result.response).to eq('Processed: test')
      end

      it 'runs the callbacks around call' do
        callback_executed = false
        callback_service = Class.new(TestService) do
          before_call do
            callback_executed = true
          end
        end

        stub_const('CallbackService', callback_service)

        CallbackService.call('test')
        expect(callback_executed).to be true
      end
    end

    context 'when validations fail' do
      let(:invalid_service_class) do
        Class.new(ActiveCall::Base) do
          attr_accessor :input

          validates :input, presence: true

          def initialize(input)
            @input = input
          end

          def call
            "Processed: #{input}"
          end
        end
      end

      before do
        stub_const('InvalidTestService', invalid_service_class)
      end

      it 'returns the service instance without calling the call method' do
        result = InvalidTestService.call(nil)
        expect(result).to be_an_instance_of(InvalidTestService)
        expect(result.response).to be_nil
      end

      it 'has errors when validations fail' do
        result = InvalidTestService.call(nil)
        expect(result).to be_invalid
        expect(result.errors[:input]).to include("can't be blank")
      end
    end

    context 'with callbacks' do
      let(:callback_service_class) do
        Class.new(ActiveCall::Base) do
          attr_accessor :input, :tracking

          def initialize(input)
            @input = input
            @tracking = []
          end

          before_call :track_before
          after_call :track_after

          def call
            @tracking << :call
            "Processed: #{input}"
          end

          private

          def track_before
            @tracking << :before
          end

          def track_after
            @tracking << :after
          end
        end
      end

      before do
        stub_const('CallbackTestService', callback_service_class)
      end

      it 'executes callbacks in the correct order' do
        result = CallbackTestService.call('test')
        expect(result.tracking).to eq([:before, :call, :after])
      end
    end
  end
end
