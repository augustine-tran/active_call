# frozen_string_literal: true

module ActiveCall
  class Error < StandardError; end

  class ValidationError < Error
    include ActiveCall::ValidationErrorable
  end

  class RequestError < Error
    include ActiveCall::RequestErrorable
  end
end
