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
  end
end
