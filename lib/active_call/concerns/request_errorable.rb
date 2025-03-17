# frozen_string_literal: true

module ActiveCall::RequestErrorable
  extend ActiveSupport::Concern

  included do
    attr_reader :response, :errors
  end

  def initialize(response = nil, errors = ActiveModel::Errors.new(self), message = nil)
    @response = response
    @errors   = errors
    message   ||= errors.full_messages.to_sentence.presence || 'Request failed'

    super(message)
  end
end
