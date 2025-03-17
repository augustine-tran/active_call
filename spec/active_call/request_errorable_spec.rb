# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveCall::RequestErrorable do
  let(:dummy_class) do
    Class.new(StandardError) do
      include ActiveCall::RequestErrorable
    end
  end

  describe '#initialize' do
    let(:mock_response) { { status: 500 } }

    it 'sets response and errors attributes' do
      errors = ActiveModel::Errors.new(Object.new)
      error = dummy_class.new(mock_response, errors)

      expect(error.response).to eq(mock_response)
      expect(error.errors).to eq(errors)
    end

    context 'when message is provided' do
      it 'uses the provided message' do
        custom_message = 'Custom error message'
        error = dummy_class.new(mock_response, ActiveModel::Errors.new(Object.new), custom_message)

        expect(error.message).to eq(custom_message)
      end
    end

    context 'when message is not provided' do
      it 'uses error messages when present' do
        errors = ActiveModel::Errors.new(Object.new)
        errors.add(:base, 'Validation error one')
        errors.add(:base, 'Validation error two')

        error = dummy_class.new(mock_response, errors)

        expect(error.message).to eq('Validation error one and Validation error two')
      end

      it 'uses default message when errors are empty' do
        errors = ActiveModel::Errors.new(Object.new)
        error = dummy_class.new(mock_response, errors)

        expect(error.message).to eq('Request failed')
      end
    end
  end
end
