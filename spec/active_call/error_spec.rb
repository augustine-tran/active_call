# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveCall::Error do
  describe 'inheritance hierarchy' do
    it 'inherits from StandardError' do
      expect(described_class).to be < StandardError
    end
  end

  describe ActiveCall::ValidationError do
    describe 'inheritance hierarchy' do
      it 'inherits from ActiveCall::Error' do
        expect(described_class).to be < ActiveCall::Error
      end
    end

    describe 'module inclusion' do
      it 'includes ValidationErrorable module' do
        expect(described_class.included_modules).to include(ActiveCall::ValidationErrorable)
      end
    end
  end

  describe ActiveCall::RequestError do
    describe 'inheritance hierarchy' do
      it 'inherits from ActiveCall::Error' do
        expect(described_class).to be < ActiveCall::Error
      end
    end

    describe 'module inclusion' do
      it 'includes RequestErrorable module' do
        expect(described_class.included_modules).to include(ActiveCall::RequestErrorable)
      end
    end
  end
end
