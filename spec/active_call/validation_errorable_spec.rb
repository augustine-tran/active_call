# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveCall::ValidationErrorable do
  let(:dummy_class) do
    Class.new(StandardError) do
      include ActiveCall::ValidationErrorable
    end
  end

  describe '#initialize' do
    it 'sets errors attribute' do
      errors = ActiveModel::Errors.new(Object.new)
      error = dummy_class.new(errors)

      expect(error.errors).to eq(errors)
    end

    context 'when message is provided' do
      it 'uses the provided message' do
        custom_message = 'Custom validation error message'
        error = dummy_class.new(ActiveModel::Errors.new(Object.new), custom_message)

        expect(error.message).to eq(custom_message)
      end
    end

    context 'when message is not provided' do
      it 'uses error messages when present' do
        errors = ActiveModel::Errors.new(Object.new)
        errors.add(:base, 'Validation error one')
        errors.add(:base, 'Validation error two')

        error = dummy_class.new(errors)

        expect(error.message).to eq('Validation error one and Validation error two')
      end

      it 'uses default message when errors are empty' do
        errors = ActiveModel::Errors.new(Object.new)
        error = dummy_class.new(errors)

        expect(error.message).to eq('Validation failed')
      end
    end
  end
end
