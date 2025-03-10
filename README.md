# Active Call

Active Call provides a standardized way to create service objects.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

Your child classes should inherit from `ActiveCall::Base`.

Now you can start adding your own service object classes in your gem's `lib` folder.

Each service object must define only one public method named `call`.

A `response` attribute is set with the result of the `call` method.

An `errors` object will be set if you specified any validations that failed before the `call` method could be invoked.

There is also a `before_call` hook to set up anything before invoking the `call` method. This only happens after all validations have passed.

Define a service object with optional validations and callbacks.

```ruby
require 'active_call'

class YourGemName::SomeResource::GetService < ActiveCall::Base
  attr_reader :message

  validates :message, presence: true

  before_call :strip_message

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
end
```

You will get a **response** object.

```ruby
service = YourGemName::SomeResource::GetService.call(message: ' bar ')
service.valid? # => true
service.response # => { foo: 'bar' }
```

And an **errors** object when validation failed.

```ruby
service = YourGemName::SomeResource::GetService.call(message: '')
service.valid? # => false
service.errors.full_messages # => ["Message can't be blank"]
service.response # => nil
```

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

Then in your application code you can overrite the configuration defaults.

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
