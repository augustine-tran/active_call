# frozen_string_literal: true

class ActiveCall::Base
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveSupport::Configurable

  attr_reader :response

  define_model_callbacks :call

  class << self
    # Set your class to `self.abstract_class = true` if the class is used as a base class and not as a service object.
    # Abstract classes are not meant to be instantiated directly, but rather inherited from.
    # The `call` method doesn't need to be implemented in abstract classes.
    #
    # Example:
    #
    #   class YourGemName::BaseService < ActiveCall::Base
    #     self.abstract_class = true
    #   end
    #
    #   class YourGemName::SomeResource::CreateService < YourGemName::BaseService
    #     def call
    #       # Implementation specific to this service.
    #     end
    #   end
    #
    attr_accessor :abstract_class

    def abstract_class?
      @abstract_class == true
    end

    def call(...)
      service_object = new(...)
      return service_object if service_object.invalid?(except_on: :response)

      service_object.run_callbacks(:call) do
        service_object.instance_variable_set(:@response, service_object.call)
        service_object.validate(:response)

        return service_object unless service_object.success?
      end

      service_object
    end

    def call!(...)
      service_object = new(...)
      raise ActiveCall::ValidationError, service_object.errors if service_object.invalid?(except_on: :response)

      service_object.run_callbacks(:call) do
        service_object.instance_variable_set(:@response, service_object.call)
        service_object.validate(:response)

        unless service_object.success?
          raise ActiveCall::RequestError.new(service_object.response, service_object.errors)
        end
      end

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

  def call
    return if self.class.abstract_class?

    raise NotImplementedError, 'Subclasses must implement a call method. If this is an abstract base class, set ' \
      '`self.abstract_class = true`.'
  end
end
