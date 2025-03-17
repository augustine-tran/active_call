# frozen_string_literal: true

class ActiveCall::Base
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveSupport::Configurable

  attr_reader :response

  define_model_callbacks :call

  class << self
    def call(...)
      service_object = new(...)
      return service_object if service_object.invalid?

      service_object.run_callbacks(:call) do
        service_object.instance_variable_set(:@response, service_object.call)
      end

      service_object
    end

    def call!(...)
      service_object = new(...)
      raise ActiveCall::ValidationError, service_object.errors if service_object.invalid?

      service_object.run_callbacks(:call) do
        service_object.instance_variable_set(:@response, service_object.call)
      end

      raise ActiveCall::RequestError.new(service_object.response, service_object.errors) unless service_object.success?

      service_object
    end
  end

  def success?
    errors.empty?
  end

  def valid?(context = nil)
    return true if response

    super
  end
end
