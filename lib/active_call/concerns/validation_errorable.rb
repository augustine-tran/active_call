# frozen_string_literal: true

module ActiveCall::ValidationErrorable
  extend ActiveSupport::Concern

  included do
    attr_reader :errors
  end

  def initialize(errors = ActiveModel::Errors.new(self), message = nil)
    @errors = errors
    message ||= errors.full_messages.to_sentence.presence || 'Validation failed'

    super(message)
  end
end
