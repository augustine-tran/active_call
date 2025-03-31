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
    # ==== Examples
    #
    #   class YourGem::BaseService < ActiveCall::Base
    #     self.abstract_class = true
    #   end
    #
    #   class YourGem::SomeResource::CreateService < YourGem::BaseService
    #     def call
    #       # Implementation specific to this service.
    #     end
    #   end
    #
    attr_accessor :abstract_class

    def abstract_class?
      @abstract_class == true
    end

    # TODO: Refactor `call` and `call!`. The only differences are the lines raising exceptions.

    # Using `call`
    #
    # ==== Examples
    #
    # You will get an `errors` object when validation fails.
    #
    #   service = YourGem::SomeResource::CreateService.call(message: '')
    #   service.success? # => false
    #   service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=blank, options={}>]>
    #   service.errors.full_messages # => ["Message can't be blank"]
    #   service.response # => nil
    #
    # A `response` object on a successful `call` invocation.
    #
    #   service = YourGem::SomeResource::CreateService.call(message: ' bar ')
    #   service.success? # => true
    #   service.response # => {:foo=>"bar"}
    #
    # And an `errors` object if you added errors during the `validate, on: :response` validation.
    #
    #   service = YourGem::SomeResource::CreateService.call(message: 'baz')
    #   service.success? # => false
    #   service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=invalid, options={:message=>"cannot be baz"}>]>
    #   service.errors.full_messages # => ["Message cannot be baz"]
    #   service.response # => {:foo=>"baz"}
    #
    def call(...)
      service_object = new(...)
      service_object.instance_variable_set(:@bang, false)
      return service_object if service_object.invalid?(except_on: [:request, :response])

      service_object.run_callbacks(:call) do
        next if service_object.is_a?(Enumerable)

        service_object.validate(:request)
        return service_object unless service_object.success?

        service_object.instance_variable_set(:@response, service_object.call)
        service_object.validate(:response)
        return service_object unless service_object.success?
      end

      service_object
    end

    # Using `call!`
    #
    # ==== Examples
    #
    # An `ActiveCall::ValidationError` exception gets raised when validation fails.
    #
    #   begin
    #     service = YourGem::SomeResource::CreateService.call!(message: '')
    #   rescue ActiveCall::ValidationError => exception
    #     exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=blank, options={}>]>
    #     exception.errors.full_messages # => ["Message can't be blank"]
    #   end
    #
    # A `response` object on a successful `call` invocation.
    #
    #   service = YourGem::SomeResource::CreateService.call!(message: ' bar ')
    #   service.success? # => true
    #   service.response # => {:foo=>"bar"}
    #
    # And an `ActiveCall::RequestError` exception gets raised if you added errors during the `validate, on: :response`
    # validation.
    #
    #   begin
    #     service = YourGem::SomeResource::CreateService.call!(message: 'baz')
    #   rescue ActiveCall::RequestError => exception
    #     exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=invalid, options={:message=>"cannot be baz"}>]>
    #     exception.errors.full_messages # => ["Message cannot be baz"]
    #     exception.response # => {:foo=>"baz"}
    #   end
    #
    def call!(...)
      service_object = new(...)
      service_object.instance_variable_set(:@bang, true)

      if service_object.invalid?(except_on: [:request, :response])
        raise ActiveCall::ValidationError, service_object.errors
      end

      service_object.run_callbacks(:call) do
        next if service_object.is_a?(Enumerable)

        service_object.validate(:request)
        raise ActiveCall::RequestError.new(nil, service_object.errors) unless service_object.success?

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

  def bang?
    !!@bang
  end

  def call
    return if self.class.abstract_class?

    raise NotImplementedError, 'Subclasses must implement a call method. If this is an abstract base class, set ' \
      '`self.abstract_class = true`.'
  end
end
