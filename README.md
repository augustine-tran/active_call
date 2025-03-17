# Active Call

Active Call provides a standardized way to create service objects.

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

Now you can start adding your own service object classes in your gem's `lib` folder or your project's `app/services` folder.

Each service object must define only one public method named `call`.

A `response` attribute is set with the result of the `call` method.

An `errors` object will be set if you specified any validations that failed before the `call` method could be invoked.

There is also a `before_call` hook to set up anything before invoking the `call` method. This only happens after all validations have passed.

You can use the `after_call` hook to add to the `errors` object if anything failed during `call`.

You also get an `around_call` hook.

Define a service object with optional validations and callbacks.

```ruby
require 'active_call'

class YourGemName::SomeResource::CreateService < ActiveCall::Base
  attr_reader :message

  validates :message, presence: true

  before_call :strip_message

  after_call :confirm_message

  def initialize(message: nil)
    @message = message
  end

  def call
    { foo: message }
  end

  private

  def strip_message
    @message.strip!
  end

  def confirm_message
    errors.add(:message, :invalid, message: 'cannot be baz') if message == 'baz'
  end
end
```

### Using `.call`

You will get a **response** object on a successful `call` invocation.

```ruby
service = YourGemName::SomeResource::CreateService.call(message: ' bar ')
service.success? # => true
service.response # => {:foo=>"bar"}
```

Or if you added to the **errors** object in the `after_call` hook.

```ruby
service = YourGemName::SomeResource::CreateService.call(message: 'baz')
service.success? # => false
service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=invalid, options={:message=>"cannot be baz"}>]>
service.errors.full_messages # => ["Message cannot be baz"]
service.response # => {:foo=>"baz"}
```

An **errors** object when validation fails.

```ruby
service = YourGemName::SomeResource::CreateService.call(message: '')
service.success? # => false
service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=blank, options={}>]>
service.errors.full_messages # => ["Message can't be blank"]
service.response # => nil
```

### Using `.call!`

You will get a **response** object on a successful `call` invocation.

```ruby
service = YourGemName::SomeResource::CreateService.call!(message: ' bar ')
service.success? # => true
service.response # => {:foo=>"bar"}
```

Or an `ActiveCall::RequestError` exception gets raised if you add to the **errors** object in the `after_call` hook.

```ruby
begin
  service = YourGemName::SomeResource::CreateService.call!(message: 'baz')
rescue ActiveCall::RequestError => exception
  exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=invalid, options={:message=>"cannot be baz"}>]>
  exception.errors.full_messages # => ["Message cannot be baz"]
  exception.response # => {:foo=>"baz"}
end
```

An `ActiveCall::ValidationError` exception gets raised when validation fails.

```ruby
begin
  service = YourGemName::SomeResource::CreateService.call!(message: '')
rescue ActiveCall::ValidationError => exception
  exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=message, type=blank, options={}>]>
  exception.errors.full_messages # => ["Message can't be blank"]
end
```

## Configuration

If you have secrets, use a **configuration** block.

```ruby
require 'net/http'

class YourGemName::BaseService < ActiveCall::Base
  config_accessor :api_key, default: ENV['API_KEY'], instance_writer: false

  def call
    Net::HTTP.get_response(URI("http://example.com/api?#{URI.encode_www_form(api_key: api_key)}"))
  end
end
```

Then in your application code you can overwite the configuration defaults.

```ruby
YourGemName::BaseService.configure do |config|
  config.api_key = Rails.application.credentials.api_key || ENV['API_KEY']
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kobusjoubert/active_call.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
