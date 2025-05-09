# Active Call

[![Gem Version](https://badge.fury.io/rb/active_call.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/active_call)

Active Call provides a standardized way to build service objects.

It helps you extract complex business logic from models and controllers, and keeps your code clean and organized.

Encouraging single responsibility improves readability, testability, and long-term maintainability.

<div align="center">
  <a href="https://platform45.com?utm_source=github&utm_content=active_call">
    <picture>
      <img src="https://github.com/user-attachments/assets/19fd40df-2ce9-4f30-8120-d53f3fbf9f07">
    </picture>
  </a>
</div>

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add active_call
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install active_call
```

## Usage

Your child classes should inherit from `ActiveCall::Base`.

You can add your own service object classes in your gem's `lib` folder or your project's `app/services` folder.

Each service object must define only one public method named `call`.

### Logic Flow

1. **Before** invoking `call`.

  - Validate the service with `validates`.

  - Use the `before_call` hook to set up anything **after validation** passes.

  - Validate the request with `validate on: :request`.

2. **During** `call` invocation.

  - A `response` attribute gets set with the result of the `call` method.

3. **After** invoking `call`.

  - Validate the response with `validate on: :response`.

  - Use the `after_call` hook to set up anything **after response validation** passes.

  - Return the service object.

If any validations fail during this flow, the service object gets returned without continuing with the subsequent steps.

### Example Service Object

Define a service object with optional validations and callbacks.

```ruby
require 'active_call'

class YourGem::SomeResource::CreateService < ActiveCall::Base
  attr_reader :message, :another_service

  validates :message, presence: true

  validate on: :request do
    errors.merge!(another_service.errors) unless another_service.success?
  end

  validate on: :response do
    errors.add(:message, :invalid, message: 'cannot be baz') if response[:foo] == 'baz'
  end

  before_call :call_another_service, :strip_message

  after_call :log_response

  def initialize(message: nil)
    @message = message
  end

  def call
    { foo: message }
  end

  private

  def call_another_service
    @another_service = YourGem::SomeResource::GetService.call(id: '1')
  end

  def strip_message
    @message.strip!
  end

  def log_response
    puts "Successfully called #{response}"
  end
end
```

### Using `call`

You will get an **errors** object when validation fails.

```ruby
service = YourGem::SomeResource::CreateService.call(message: '')
service.success? # => false
service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=blank, options={}>]>
service.errors.full_messages # => ["Message can't be blank"]
service.response # => nil
```

A **response** object on a successful `call` invocation.

```ruby
service = YourGem::SomeResource::CreateService.call(message: ' bar ')
service.success? # => true
service.response # => {:foo=>"bar"}
```

And an **errors** object if you added errors during the `validate, on: :response` validation.

```ruby
service = YourGem::SomeResource::CreateService.call(message: 'baz')
service.success? # => false
service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=invalid, options={:message=>"cannot be baz"}>]>
service.errors.full_messages # => ["Message cannot be baz"]
service.response # => {:foo=>"baz"}
```

### Using `call!`

An `ActiveCall::ValidationError` **exception** gets raised when validation fails.

```ruby
begin
  service = YourGem::SomeResource::CreateService.call!(message: '')
rescue ActiveCall::ValidationError => exception
  exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=blank, options={}>]>
  exception.errors.full_messages # => ["Message can't be blank"]
end
```

A **response** object on a successful `call` invocation.

```ruby
service = YourGem::SomeResource::CreateService.call!(message: ' bar ')
service.success? # => true
service.response # => {:foo=>"bar"}
```

And an `ActiveCall::RequestError` **exception** gets raised if you added errors during the `validate, on: :response` validation.

```ruby
begin
  service = YourGem::SomeResource::CreateService.call!(message: 'baz')
rescue ActiveCall::RequestError => exception
  exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=invalid, options={:message=>"cannot be baz"}>]>
  exception.errors.full_messages # => ["Message cannot be baz"]
  exception.response # => {:foo=>"baz"}
end
```

## Configuration

If you have secrets, use a **configuration** block.

```ruby
class YourGem::BaseService < ActiveCall::Base
  self.abstract_class = true

  config_accessor :api_key, default: ENV['API_KEY'], instance_writer: false
end
```

Then in your application code you can override the configuration defaults.

```ruby
YourGem::BaseService.configure do |config|
  config.api_key = Rails.application.credentials.api_key || ENV['API_KEY']
end
```

And implement a service object like so.

```ruby
require 'net/http'

class YourGem::SomeResource::CreateService < YourGem::BaseService
  def call
    Net::HTTP.get_response(URI("http://example.com/api?#{URI.encode_www_form(api_key: api_key)}"))
  end
end
```

## Gem Creation

To create your own gem for a service.

```bash
gem update --system
```

Build your gem.

```bash
bundle gem your_service --test=rspec --linter=rubocop --ci=github --github-username=<your_profile_name> --git --changelog --mit
```

Then add Active Call as a dependency in your gemspec.

```ruby
spec.add_dependency 'active_call'
```

Now start adding your service objects in the `lib` directory and make sure they inherit from `ActiveCall::Base`.

## Active Call Extensions

- [Active Call - API](https://rubygems.org/gems/active_call-api)

## Gems Using Active Call

- [Active Call - nCino KYC DocFox](https://rubygems.org/gems/active_call-doc_fox)
- [Active Call - Zoho Sign](https://rubygems.org/gems/active_call-zoho_sign)
- [Active Call - Zoho CRM](https://rubygems.org/gems/active_call-zoho_crm)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/activecall/active_call.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
