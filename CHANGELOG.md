## [Unreleased]

## [0.2.0] - 2025-03-20

- Added method `.call!` with a bang, which will raise an `ActiveCall::ValidationError` exception when validation fails and an `ActiveCall::RequestError` exception when errors were added to the service object in the `after_call` callback.
- Use new method `success?` instead of `valid?`.
- Method `valid?` will return `true` if the service object passed validation and was able to make the `call` method.
- Use `validate, on: :response` to validate the response object.
- Raise `NotImplementedError` when `call` is not defined in subclasses.
- Use `self.abstract_class = true` to treat the class as a base class that does not define a `call` method.
- Adding a `@bang` instance variable on the service objects to determine if `call` or `call!` was invoked.
- Don't set `@response` if the object is an `Enumerable`. The response will be set in `each` and not `call`.

## [0.1.0] - 2025-03-08

- Initial release
