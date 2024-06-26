# Monads

## Table of Contents
* [Description](#description)
* [Maybe](#maybe)
* [Try](#try)
* [Result](#result)

## Description

This module is introduced to replace `dry-monads` with custom monads implementation which plays better with sorbet
type-checking. If you haven't worked with monads and don't know what's that, check [dry-monads documentation](https://dry-rb.org/gems/dry-monads/1.3/) first.
This should help you to get an idea of monads.

Now let's dive deeper into different kinds of monads.

## Maybe

This is probably the simplest monad that represents a series of computations could return `nil` at any point.
This monad is [parameterized](https://sorbet.org/docs/generics) with a type of value. Basically, the `Maybe` is supertype
of two subtypes: `Some` and `None` that shares the same interface. `Some` subtype contains a value, `None` doesn't contain
anything and represents `nil`.

### Initialization

The monad can be created with two primary constructors `Maybe` and `None` (note that these are methods).
Method `#Maybe` wraps a nilable value with a `Maybe` class: if a value is nil, than it returns value of `None`,
if the value is present, it returns instance of `Some`. In order to access these helpers`Mayak::Monads::Maybe::Mixin` must be included first:

```ruby
include Mayak::Monads::Maybe::Mixin

sig { params(numbers: T::Array[Integer]).returns(T.nilable(Integer)) }
def first(numbers)
  numbers.first
end

Maybe(first[])  # None
Maybe(first[1]) # Some[Integer](value = 1)
```

Also, the monad can be instantiated directly with `Mayak::Monads::Maybe::Some` and `Mayak::Monads::Maybe::None`:

```ruby
sig { returns(Mayak::Monads::Maybe[Integer]) }
def some
  Mayak::Monads::Maybe::Some[Integer].new(10)
end

sig { returns(Mayak::Monads::Maybe[Integer]) }
def none
  Mayak::Monads::Maybe::None[Integer].new
end
```

### Unpacking

In order to retrieve a value from a `Maybe` a method `#value` which is defined on `Mayak::Monads::Maybe::Some` can be used.
`Mayak::Monads::Maybe::Some` is a subtask of `Maybe`. Note that the accessor is only defined on `Some` subtype, so if the `#value`
method will be called on an instance of `Maybe`, Sorbet will not type-check, since `Maybe` doesn't have this method.
In order to access value of `Maybe`, it need to be verified first that the monad is instance of `Some`, and only after that
this method can invoked. The most convenient way to do this is to use case-when statement.

```ruby
sig { params(a: Integer, b: Integer).returns(Mayak::Monads::Maybe[Integer]) }
def divide(a, b)
  if b == 0
    None()
  else
    Maybe(a / b)
  end
end

sig { params(a: Integer, b: Integer).void }
def print_result_divide(a, b)
  result = divide(a, b)
  case result
  when Mayak::Monads::Maybe::Some
    # sorbet's flow-typing down-casts result to Mayak::Monads::Maybe::Some
    # so type of this variable is Mayak::Monads::Maybe::Some in this branch
    puts "#{a} / #{b} = #{result.value}"
  when Mayak::Monads::Maybe::None
    puts "Division by zero"
  else
    T.absurd(result)
  end
end

print_result_divide(10, 2) # 10 / 2 = 5
print_result_divide(10, 0) # Division by zero
```

The other way is to use method `#value_or` which returns either a value if the monad is `Some`, or
fallback value if the monad is `None`:

```ruby
divide(10, 2).value_or(0) # 5
divide(10, 0).value_or(0) # 0
```

### Methods

#### `#to_dry`

Converts an instance of a monad in to an instance of corresponding dry-monad.

```ruby
include Mayak::Monads::Maybe::Mixin

Maybe(10).to_dry  # Some(10): Dry::Monads::Maybe::Some
Maybe(nil).to_dry # None:  Dry::Monads::Maybe::None
```

#### `.from_dry`

Converts instance of `Dry::Monads::Maybe` into instance `Mayak::Monads::Maybe`

```ruby
include Mayak::Monads

Maybe.from_dry(Dry::Monads::Some(10)) # Some[Integer](value = 20)
Maybe.from_dry(Dry::Monads::None())   # None
```

#### `#map`

The same as `fmap` in a dry-monads `Maybe`. Allows to modify the value with a block if it's present.

```ruby
sig { returns(Mayak::Monads::Maybe[Integer]) }
def some
  Mayak::Monads::Maybe::Some[Integer].new(10)
end

sig { returns(Mayak::Monads::Maybe[Integer]) }
def none
  Mayak::Monads::Maybe::None[Integer].new
end

some.map { |a| a + 20 } # Some[Integer](value = 20)
none.map { |a| a + 20 } # None[Integer]
```

#### `#flat_map`
The same as `bind` in a dry-monads `Maybe`. Allows to modify the value with a block that returns another `Maybe`
if it's present, otherwise returns `None`. If the block returns `None`, the whole computation returns `None`.

```ruby
sig { params(a: Integer, b: Integer).returns(Mayak::Monads::Maybe[Integer]) }
def divide(a, b)
  if b.zero?
    Mayak::Monads::Maybe::None[Integer].new
  else
    Mayak::Monads::Maybe::Some[Integer].new(a / b)
  end
end

divide(20, 2).flat_map { |a| divide(a, 2) } # Some[Integer](value = 5)
divide(20, 2).flat_map { |a| divide(a, 0) } # None
divide(20, 0).flat_map { |a| divide(a, 2) } # None
```

#### `#filter`

Receives a block the returns a boolean value and checks the underlying value with the block when a monad is `Some`.
Returns `None` if the block called on the value returns `false`, and returns `self` if the block returns `true`.
Returns `None` if the monad is `None`.

```ruby
divide(20, 2).filter { |value| value > 5 } # Some[Integer](value = 10)
divide(20, 2).filter { |value| value < 5 } # None
divide(20, 0).filter { |value| value < 5 } # None
```

#### `#some?`

Returns true if a `Maybe` is a `Some` and false if it's `None`.

```ruby
divide(20, 2).some? # true
divide(20, 0).some? # false
```

#### `#none?`

Returns true if a `Maybe` is a `None` and false if it's `Some`.

```ruby
divide(20, 2).none? # false
divide(20, 0).none? # true
```

#### `#value_or`

Unpack a `Maybe` and returns its value if it's a `Some`, or returns provided fallback value if it's a `None`.

```ruby
divide(20, 2).value_or(0) # 10
divide(20, 0).value_or(0) # 0
```

#### `#to_task`

Converts a value to task. If a `Maybe` is an instance of `Some`, it returns succeeded task, if it's a `None`,
it returns failed task with a provided error.

```ruby
task = Mayak::Concurrent::Task.execute { 100 }
error = StandardError.new("Division by zero")
task.flat_map { |value| divide(value, 10).to_task(error) }.await! # 10
task.flat_map { |value| divide(value, 0).to_task(error) }.await!  # StandardError: Divison by zero
```

#### `#to_result`

Converts a `Maybe` into a `Result`. If the `Maybe` is a `Some`, returns `Result::Success` with a value of the `Maybe`.
If it's a `None`, returns `Result::Failre` with a value of an error provided as an argument.

```ruby
divide(10, 2).to_result("Division by zero") # Success: Result[String, Integer](value = 5)
divide(10, 0).to_result("Division by zero") # Failure: Result[String, Integer](error = "Division by zero")
```

#### `#to_try`

Converts a `Maybe` into a `Try`. If the `Maybe` is a `Some`, returns `Try::Success` with a value of the `Maybe`.
If it's a `None`, returns `Try::Failre` with a value of an error provided as an argument.

```ruby
divide(10, 2).to_try(StandardError.new("Division by zero")) # Success: Try[Integer](value = 5)
divide(10, 0).to_try(StandardError.new("Division by zero")) # Failure: Try[Integer](error = StandardError(message = "Division by zero"))
```

Combination of `Maybe` constructor with `#to_try` method allows to significantly simplify common
pattern: checking nullability of a value, and returning error if the value is missing:
```ruby
sig { params(user: User).returns(Try[Address]) }
def get_address(user)
  address = user.contact.address

  if address.present?
    Success(address)
  else
    Failure(AddressMissingError.new("Missing address for User(id=#{user.id})"))
  end
end
```

With `Maybe` and `#to_try`:

```ruby
sig { params(user: User).returns(Try[Address]) }
def get_address(user)
  Maybe(user.contact.address).to_try(
    AddressMissingError.new("Missing address for User(id=#{user.id})")
  )
end
```

#### `#tee`

If a `Maybe` is an instance of `Some`, runs a block with a value of `Some` passed, and returns the monad itself
unchanged. Doesn't do anything if it's a `None`.

```ruby
divide(10, 2).tee { |a| puts a }
# returns: Some[Integer](value = 5)
# console: 5

divide(10, 0).tee { |a| puts a }
# returns: None
```

Can be useful to embed side-effects into chain of monad transformation:
```ruby
sig { params(a: Integer, b: Integer).returns(Maybe[String]) }
def run(a, b)
  divide(a, b)
    .tee { |value| logger.info("#{a} / #{b} = #{value}") }
    .map { |value| value * 100 }
    .tee { |value| logger.info("Intermediate result = #{value}") }
    .map(&:to_s)
end
```

#### `#recover`

Converts `None` into a `Some` with a provided value. If the monad is an instance of `Some`, returns itself.

```ruby
divide(10, 2).recover(0) # Some[Integer](value = 5)
divide(10, 0).recover(0) # Some[Integer](value = 0)
```

#### `.sequence`
`Maybe.sequence` takes an array of `Maybe`s and transform it into a `Maybe` of an array.
If all elements of an argument array is `Some`, then result will be `Some` of the array, otherwise
it will `None`.

```ruby
values = [Maybe(1), Maybe(2), Maybe(3)]
Maybe.sequence(values) # Some([10, 5, 3])

values = values = [Maybe(nil), Maybe(2), Maybe(3)]
Maybe.sequence(values) # None
```

#### `.check`

Receives a value and block returning a boolean value. If the block returns true,
the method returns the value wrapped in `Some`, otherwise it returns `None`:

```ruby
Maybe.check(10) { 20 > 10 } # Some[Integer](10)
Maybe.check(20) { 10 > 20 } # None
```

#### `.guard`

Receives a block returning a boolean value. If the block returns true,
the method returns a `Some` containing `nil`, otherwise `None` is returned:

```ruby
Maybe.guard { 20 > 10 } # Some[NilClass](nil)
Maybe.guard { 10 > 20 } # None
```

### Do-notation

Using `map` and `flat_map` for monads chaining can be really tedious, especially when computation
requires combining different values from branches.

Let's take a look at the following code snippet.

```ruby
sig { abstract.params(id: Integer).returns(Maybe[User]) }
def fetch_user(id)
end

sig { abstract.params(city: String, address: Address).returns(Maybe[Coordinates]) }
def fetch_city_coordinates(city, address)
end

sig { abstract.params(user: User, coordinates: Coordinates).returns(Maybe[UserAddressCache]) }
def fetch_user_address_cache(user, coordinates)
end

sig {
  abstract
    .params(user: User, address: Address, coordinates: Coordinates, cache: UserAddressCache)
    .returns(Maybe[UserAddressData])
}
def build_user_address_data(user, address, coordinates, cache)
end

sig { params(user_id: Integer).returns(Maybe[UserAddressData]) }
def run(user_id)
  fetch_user(user_id).flat_map { |user|
    user
      .address
      .flat_map { |address|
        address
          .city
          .flat_map { |city| fetch_city_coordinates(city) }
          .flat_map { |coordinates|
            fetch_user_address_cache(user, coordinates).flat_map { |cache|
              build_user_address_data(user, address, coordinates, cache)
            }
          }
      }
  }
end
```

Don't worry if you can't really understand what's going on here, the code is intentionally overcomplicated to show you
to which extremes `#map` and `#flat_map` can lead.

In order to simplify computation you can use Do-notation. Let's see the same `run` method with using
Do-notation instead of `#map` and `#flat_map` chaining, and let's break down how it's work:

```ruby
# Make sure you have the Mixin included
include Mayak::Monads::Maybe::Mixin

sig { params(user_id: Integer).returns(Maybe[UserAddressCache]) }
def run(user_id)
  for_maybe {
    user        = do_maybe! fetch_user(user_id)
    address     = do_maybe! user.address
    city        = do_maybe! address.city
    coordinates = do_maybe! fetch_city_coordinates(city)
    cache       = do_maybe! fetch_user_address_cache(user, coordinates)
    do_maybe! build_user_address_data(user, address, coordinates, cache)
  }
end
```

Do-notation basically consists from two methods `for_maybe` and `do_maybe!`. `for_maybe` creates
a Do-notation scope within which you can use `do_maybe!` to unpack Monad values. If `do_maybe!` receives
a `Some` value, it unpacks it and returns underlying values, if it receives a `None`, it short circuits execution,
and the whole `for_maybe` block returns `None`. Otherwise `for_maybe` returns result of the last
expression wrapped into `Maybe`.

Let's check a few examples:

```ruby
result = for_maybe {
  a = do_maybe! Maybe(10)
  puts a # Prints: 10
  b = do_maybe! Maybe(20)
  puts b # Prints: 20
  a + b
}
result # Some[Integer](value = 30)

failure = for_maybe {
  a = do_maybe! Maybe(10)
  b = do_maybe! None # stops execution here
  puts "Not getting here" # Doesn't print anything
  a + b
}
failure # None
```
You can also you methods `check_maybe!` and `guard_maybe!` to assert some invariants
in do-notation blocks. These methods are specialized helpers of `Maybe.check` and `Maybe.guard` for
more convenient usage in do-notation blocks:

```ruby
user = for_maybe {
  user    = do_maybe! fetch_user(user_id)
  company = do_maybe! fetch_company(company_id)
  # abrupt execution if block returns false
  # or return user if block returns false
  #
  # semantically equivalent to:
  # if user.works_in?(company)
  #   do_maybe! Some(user)
  # else
  #   do_maybe! None.new
  # end
  check_maybe!(user) { user.works_in?(company) }
}

for_maybe {
  api_key = do_maybe! Maybe(params[:api_key])
  # abrupt execution if block returns None
  #
  # semantically equivalent to:
  # if validate_api_key(api_key)
  #   do_maybe! Some(nil)
  # else
  #   do_maybe! None.new
  # end
  guard_maybe! { validate_api_key(api_key) }

  perform_query
}
```

A major improvement upon `dry-monads` do-notation, is that `Mayak::Monad`s do-notation if fully typed.
Do-notations infers both result type of the whole computation, and a type of a value unwrapped by `do_maybe!`

```ruby
for_maybe {
  value = do_maybe! Maybe(10)
  T.reveal_type(value)
  value
}
# > Revealed type: Integer

result = for_maybe {
  value = do_maybe! Maybe(10)
  value
}
T.reveal_type(result)
# > Revealed type: Integer
```

## Try

`Try` monad represents result of a computation that can succeed with an arbitrary value, or fail with an error of a subtype of `StandardError`.
`Try` has two subtypes: `Failure` which contains an instance of subtype of `StandardError` and represents failure case,
and `Success`, which contains a success value of given type.

### Initialization

The primary way to create an instance of `Try` is to use constructor method `#Try` from `Mayak::Monads::Try::Mixin`.
This method receives a block that may raise exceptions. If an exception has been raised inside the block,
the method will return instance of `Try::Failure` containing an error. Otherwise the method will return result of the block
wrapped into `Try::Success`

```ruby
include Mayak::Monads::Try::Mixin

Try { 10 } # Try::Success[Integer](@value=10)
Try {
  a = "Hello "
  b = "World!"
  a + b
} # Try::Success[String](@value="Hello World!")

Try {
  a = 10
  b = 0
  a / b
} # Try::Failure[Integer](@failure=#<ZeroDivisionError: divided by 0>)
```

Note that constructor is able to infer a type of value from type returned from the block:

```ruby
sig { params(a: Integer, b: Integer).returns(Try[Integer]) }
def divide(a, b)
  Try { a / b }
end
```

Exception should be an instance of `StandardError`s subtype to be captured:
```ruby
Try { raise Exception.new("Not going to be captured") }
# > Exception: Not going to be captured
```

`#Try` can receive types of arguments to be captured. If exceptions of other types were raised, they won't
captured. Types of exceptions should be subtypes of `StandardError`:

```ruby
class CustomError < StandardError
end

Try(CustomError) {
  raise CustomError.new
} # Try::Failure[T.noreturn](@failure=#<CustomError: CustomError>)

Try(CustomError) {
  raise StandardError.new("Not going to be captured")
}
# > StandardError: Not going to be captured
```

`Try` allows to specify multiple error types:
```ruby
class CustomError1 < StandardError
end

class CustomError2 < StandardError
end

Try(CustomError1, CustomError2) {
  raise CustomError1.new
} # Try::Failure[T.noreturn](@failure=#<CustomError: CustomError>)

Try(CustomError1, CustomError2) {
  raise CustomError2.new
} # Try::Failure[T.noreturn](@failure=#<CustomError: CustomError>)

Try(CustomError1, CustomError2) {
  raise StandardError.new("Not going to be captured")
}
# > StandardError: Not going to be captured
```

`Try` can also be initialized directly be invoking constructors of its subtypes:
```ruby
Mayak::Monads::Try::Success[Integer].new(10) # Try::Success[Integer](@value=10)
Mayak::Monads::Try::Failure[Integer].new(StandardError.new) # Try::Failure[Integer](@failure=#<StandardError: StandardError>)
```

### Unpacking

Since `Try` can either contain success value in `Success` branch or error in `Failure` branch, there are specific accessors
for success and failure values. In order to check whether a `Try` contains a successful value or value,
predicates `#failure?` and `#success?` can be used:

```ruby
Try { 10 }.success? # true
Try { 10 }.failure? # false

Try { raise "Error" }.success? # false
Try { raise "Error" }.failure? # true
```

In order to retrieve a successful value from `Try`, a method `#success` can be used. This method is only defined
on `Mayak::Monads::Try::Success`, which is subtype of `Mayak::Monads::Try`. In order to invoke this method without getting an error from sorbet,
instance of `Try` should be first coerced to checked and coerced to `Try::Success`. This can be done safely with pattern matching:

```ruby
try = Try { 10 }
value = case try
when Mayak::Monads::Try::Success
  try.success
else
  nil
end
value # 10
```

If an instance of `Try` is a `Failure`, error can be retrieved via `#failure`:

```ruby
try = Try { raise "Error" }
value = case try
when Mayak::Monads::Try::Failure
  try.failure
when
  nil
end
value # #<StandardError: Error>
```

Success and failure values can be retrieved via methods `#success_or` and `#failure_or` as well. These methods
receives fallback values:

```ruby
Try { 10 }.success_or(0) # 10
Try { 10 }.failure_or(StandardError.new("Error")) # #<StandardError: Error>

Try { raise "Boom" }.success_or(0) # 0
Try { raise "Boom" }.failure_or(StandardError.new("Error")) # #<StandardError: Boom>
```

### Methods

#### `#to_dry`

Converts an instance of a monad in to an instance of corresponding dry-monad.

```ruby
include Mayak::Monads::Try::Mixin

Try { 10 }.to_dry  # Try::Value(10)
Try { raise "Error" }.to_dry # Try::Error(RuntimeError: Error)
```


#### `.from_dry`

Converts instance of `Dry::Monads::Try` into instance `Mayak::Monads::Try`

```ruby
include Mayak::Monads

error = StandardError.new("Error")
Try.from_dry(Dry::Monads::Try::Value.new([StandardError], 10)) # Try::Success[T.untyped](value = 10)
Try.from_dry(Dry::Monads::Try::Error.new(error))   # Try::Failure[T.untyped](error=#<StandardError: Error>)
```

Unfortunately `.from_dry` doesn't preserve types due to the way `Dry::Monads::Try` is written, so
this method always returns `Mayak::Monads::Try[T.untyped]`.

#### `#map`

The same as `fmap` in a dry-monads `Try`. Allows to modify the value with a block if it's present.

```ruby
sig { returns(Mayak::Monads::Try[Integer]) }
def success
  Mayak::Monads::Try::Success[Integer].new(10)
end

sig { returns(Mayak::Monads::Try[Integer]) }
def failure
  Mayak::Monads::Try::Failure[Integer].new(StandardError.new("Error"))
end

success.map { |a| a + 20 } # Success[Integer](value = 20)
failure.map { |a| a + 20 } # Failure[Integer](error=#<StandardError: Error>)
```

#### `#flat_map`
The same as `bind` in a dry-monads `Try`. Allows to modify the value with a block that returns another `Try`
if it's a`Success`, otherwise returns `Failure`. If the block returns `Failure`, the whole computation returns `Failure`.

```ruby
sig { params(a: Integer, b: Integer).returns(Mayak::Monads::Try[Integer]) }
def divide(a, b)
  Try { a / b }
end

divide(20, 2).flat_map { |a| divide(a, 2) } # Try::Success[Integer](value = 5)
divide(20, 2).flat_map { |a| divide(a, 0) } # Try::Failure[Integer](@failure=#<ZeroDivisionError: divided by 0>)
divide(20, 0).flat_map { |a| divide(a, 2) } # Try::Failure[Integer](@failure=#<ZeroDivisionError: divided by 0>)
```

#### `#filter_or`

Receives a block the returns a boolean value and checks the underlying value with the block when a monad is `Success`.
Returns `Failure` with provided error if the block called on the value returns `false`, and returns `self` if the block returns `true`.
Returns self if the original monad is `Failure`.

```ruby
error = StandardError.new("Provided error")
divide(20, 2).filter_or(error) { |value| value > 5 } # Try::Success[Integer](value = 5)
divide(20, 2).filter_or(error) { |value| value < 5 } # Try::Failure[Integer](@failure=#<StandardError: Provided error>)
divide(20, 0).filter_or(error) { |value| value < 5 } # Try::Failure[Integer](@failure=#<ZeroDivisionError: divided by 0>)
```

#### `#success?`

Returns true if a `Try` is a `Success` and false if it's a `Failure`.

```ruby
divide(20, 2).success? # true
divide(20, 0).success? # false
```

#### `#failure?`

Returns true if a `Try` is a `Failure` and false if it's a `Success`.

```ruby
divide(20, 2).failure? # false
divide(20, 0).failure? # true
```

#### `#success_or`

Unpack a `Try` and returns its success value if it's a `Success`, or returns provided fallback value if it's a `Failure`.

```ruby
divide(20, 2).value_or(0) # 10
divide(20, 0).value_or(0) # 0
```

#### `#failure_or`

Unpack a `Try` and returns its error if it's a `Failure`,
or returns provided fallback error of `StandardError` subtype if it's a `Success`.

```ruby
divide(20, 2).failure_or(StandardError.new("Error")) # #<StandardError: Error>
divide(20, 0).failure_or(StandardError.new("Error")) # #<ZeroDivisionError: divided by 0>
```

#### `#either`

Receives two functions: one from an error to a result
value (failure function), and another one from successful value to a result value (success function).
If a `Try` is an instance of `Success`, applies success function to a success value,
otherwise applies error function to an error. Note that both functions must have the same return type.

```ruby
divide(10, 2).either(
  -> (error) { error.message },
  -> (value) { value.to_s }
) # 5

divide(10, 0).either(
  -> (error) { error.message },
  -> (value) { value.to_s }
) # Division by zero
```

#### `#tee`

If a `Try` is an instance of `Success`, runs a block with a value of `Success` passed, and returns the monad itself
unchanged. Doesn't do anything if the monad is an instance of `Failure`.

```ruby
divide(10, 2).tee { |a| puts a }
# returns: Try::Success[Integer](value = 5)
# console: 5

divide(10, 0).tee { |a| puts a }
# returns: Try::Failure[Integer](@failure=#<ZeroDivisionError: divided by 0>)
```

Can be useful to embed side-effects into chain of monad transformation:
```ruby
sig { params(a: Integer, b: Integer).returns(Try[String]) }
def run(a, b)
  divide(a, b)
    .tee { |value| logger.info("#{a} / #{b} = #{value}") }
    .map { |value| value * 100 }
    .tee { |value| logger.info("Intermediate result = #{value}") }
    .map(&:to_s)
end
```

#### `#map_failure`

Transforms an error with a block if a monad is `Failure`. Returns itself otherwise. Note that the passed block
should return an instance of `StandardError`, or an instance of a subtype of the `StandardError`.

```ruby
divide(10, 0).map_failure { |error| CustomError.new(message) } # Try::Failure[Integer](@failure=#<CustomError: Division by zero>)
divide(10, 2).map_failure { |error| CustomError.new(message) } # Try::Success[Integer](@value=5)
```

#### `#flat_map_failure`

Transforms an error with a block that returns an instance of `Try` if a monad is `Failure`. Returns itself otherwise.
Allows to recover from error with a computation, that can fail too.

```ruby
divide(10, 2).flat_map_failure { |_error|
  Mayak::Monads::Try::Success[Integer].new(10)
} # Try::Success[Integer](@value=5)

divide(10, 2).flat_map_failure { |error|
  Mayak::Monads::Try::Failure[Integer].new(StandardError.new(error.message))
} # Try::Success[Integer](@value=5)

divide(10, 0).flat_map_failure { |error|
  Mayak::Monads::Try::Success[Integer].new(10)
} # Try::Success[Integer](@value=2)

divide(10, 0).flat_map_failure { |error|
  Mayak::Monads::Try::Failure[Integer].new(CustomError.new(error.message))
} # Try::Failure[Integer](@failure=#<CustomError: Division by zero>)
```

#### `#to_result`

Converts a `Try` into a `Result`. If the `Try` is a `Try::Success`, returns `Result::Success` with a success value.
If it's a `Failure`, returns `Result::Failre` with a an error value.

```ruby
divide(10, 2).to_result # Result::Success[StandardError, Integer](value = 5)
divide(10, 0).to_result # Result::Failure[StandardError, Integer](error = #<ZeroDivisionError: divided by 0>)
```

#### `#to_task`

Converts a value to task. If a `Try` is an instance of `Success`, it returns succeeded task, if it's a `Failure`,
it returns failed task with an `Failure`'s error.

```ruby
task = Mayak::Concurrent::Task.execute { 100 }
task.flat_map { |value| divide(value, 10).to_task }.await! # 10
task.flat_map { |value| divide(value, 0).to_task }.await!  # StandardError: Divison by zero
```

#### `#to_maybe`

Converts a `Try` value to `Maybe`. When the `Try` instance is a `Success`, returns `Maybe` containing successful value.
When the `Try` is an instance of `Failure`, returns `None`. Note that during the transformation error is lost.

```ruby
divide(10, 2).to_maybe # Some[Integer](value = 5)
divide(10, 0).to_maybe # None[Integer]
```

#### `#as`

Substitutes successful value in `Try::Success` with a new value, if the monad is instance of `Try::Failure`, returns
the monad unchanged.

```ruby
divide(10, 2).as("Success")# Try::Success[String](@value="Success")
divide(10, 0).as("Success") # Try::Failure[String](@failure=#<ZeroDivisionError: Division by zero>)
```

#### `#failure_as`

Substitutes an error `Try::Failure` with a new error, if the monad is instance of `Try::Success`, returns
the monad unchanged.

```ruby
divide(10, 2).failure_as(StandardError.new("Error")) # Try::Success[Integer](@value=5)
divide(10, 0).failure_as(StandardError.new("Error")) # Try::Failure[Integer](@failure=#<StandardError: Error>)
```

#### `#recover`

Converts `Failure` into a `Success` with a provided value. If the monad is an instance of `Success`, returns itself.
Basically, recovers from an error with a successful value.

```ruby
divide(10, 2).recover(0) # Try::Success[Integer](value = 5)
divide(10, 0).recover(0) # Try::Success[Integer](value = 5)
```

#### `#recover_on`

Converts `Failure` into a `Success` with a provided value if an error is an instance of a subtype of provided class. If the monad is an instance of `Success`, returns itself.
Allows to recover from specific errors.

```ruby
class CustomError1 < StandardError
end

class CustomError2 < StandardError
end

failure1 = Mayak::Monads::Try::Failure[String].new(CustomError1.new("Error1"))
failure2 = Mayak::Monads::Try::Failure[String].new(CustomError2.new("Error2"))

failure1.recover_on(CustomError1) { |error| error.message } # Try::Success[String](@value="Error1")
failure2.recover_on(CustomError1) { |error| error.message } # Try::Failure[String](@failure=#<CustomError2: Error2>)
```

Note, that an error passed in the block is not down casted. So from sorbet perspective it still will be
a `StandardError`.

```ruby
failure1.recover_on(CustomError1) { |error|
  T.reveal_type(error)
  "Error"
}
# Revealed type: StandardError
```

#### `#recover_with`

Alias for `#flat_map_failure`.

#### `.sequence`
`Try.sequence` takes an array of `Try`s and transform it into a `Try` of an array.
If all elements of the array is `Success`, then the method returns `Try::Sucess` containing array of values,
otherwise the method returns `Try::Failure` containing first error.

```ruby
include Mayak::Monads

values = [
  Try::Success[Integer].new(1),
  Try::Success[Integer].new(2),
  Try::Success[Integer].new(3)
]
Try.sequence(values) # Try::Success[T::Array[Integer]](@value=[1, 2, 3])

values = [
  Try::Success[Integer].new(1),
  Try::Failure[Integer].new(ArgumentError.new("Error1")),
  Try::Failure[Integer].new(StandardError.new("Error2"))
]
Try.sequence(values) # Try::Failure[Integer](@failure=#<ArgumentError: Error1>)
```

#### `.check`

Receives a value, an error, and block returning a boolean value. If the block returns true,
the method returns the value wrapped in `Try::Success`, otherwise it returns `Try::Failure` containing the error:

```ruby
error = StandardError.new("Error")
Try.check(10, error) { 20 > 10 } # Try::Success[Integer](@failure=10)
Try.check(20, error) { 10 > 20 } # Try::Failure[Integer](@failure=#<StandardError: Error>)
```

#### `.guard`

Receives a block returning a boolean value, and an error. If the block returns true,
the method returns `Try::Success` containing nil, otherwise it returns `Try::Failure` containing an error:

```ruby
error = StandardError.new("Error")
Maybe.guard(error) { 20 > 10 } # Try::Success[NilClass](@failure=nil)
Maybe.guard(error) { 10 > 20 } # Try::Failure[NilClass](@failure=#<StandardError: Error>)
```

This method may be useful in do-notations when you need need to check some invariant and perform
an early return if it doesn't hold.

### Do-notation

`Try` monad supports `do-notation` just like `Maybe` monad. Check do-notation chapter of [Maybe](#maybe) for motivation.
Do-notation for `Try` is quite similar for `Maybe`'s do-notation, albeit there are some differences in syntax and semantics.
Do-notation scope is created via method `for_try`, a monad is unwrapped via `do_try!`.

```ruby
result = for_try {
  first  = do_try! Try::Success[Integer].new(10)
  second = do_try! Try::Success[Integer].new(20)
  first + second
}
result # Try::Success[Integer](@value=30)
```

When an instance of `Try::Failure` is unwrapped via `do_try!` the whole computation returns this monad.

```ruby
result = for_try {
  first  = do_try! Try::Success[Integer].new(10)
  second = do_try! Try::Failure[Integer].new(StandardError.new("Error"))
  third  = do_try! Try::Success[Integer].new(20)
  first + second + third
}
result # Try::Failure[Integer](@failure=#<StandardError: Error>)
```

Methods `check_try!` and `guard_try!` to perform early returns.

```ruby
sig { params(a: Integer, b: Integer).returns(Try[Float]) }
def compute(a, b)
  argument_error = ArgumentError.new("Argument is less than zero")
  for_try {
    guard_try! (argument_error) { a < 0 || b < 0 }
    first  = do_try! Try { a / b }
    second = do_try! Try { Math.log(a, b) }
    result = first + second
    check_try!(result, StandardError.new("Number is too big")) { result < 100 }
  }
end
```

Do-notation for `Try` is fully typed as well.

```ruby
for_try {
  value = do_try! Try { 10 }
  T.reveal_type(value)
  value
}
# > Revealed type: Integer

result = for_try {
  value = do_try! Try { 10 }
  value
}
T.reveal_type(result)
# > Revealed type: Integer
```

## Result

`Result` monad represents result of a computation that can succeed with an arbitrary value, or fail with an arbitrary error.
As `Try`, `Result` has two subtypes: `Failure` which contains an error and represents failure case, and `Success`, which contains
a success value. The difference between `Result` and `Try`, is that `Result` has arbitrary error type, while `Try` has it fixed to `StandardError`.


### Initialization

The primary way to create an instance of `Try` is to use constructor method `#Try` from `Mayak::Monads::Try::Mixin`.
This method receives a block that may raise exceptions. If an exception has been raised inside the block,
the method will return instance of `Try::Failure` containing an error. Otherwise the method will return result of the block
wrapped into `Try::Success`

`Result` can be created via primary constructors of `Result::Success` and `Result::Failure`:

```ruby
include Mayak::Monads

Result::Success[String, Integer].new(10)
Result::Failure[String, Integer].new("Error")
```

### Unpacking

Accessing values of `Result` performed in the same as for `Try`.

```ruby
success  = Result::Success[String, Integer].new(10)
failure = Result::Failure[String, Integer].new("Error")
success.success? # true
success.failure? # false

failure.success? # false
failure.failure? # true
```

Successful and failure values can be accessed via `#success` and `#failure` values. These methods
are defined on `Result::Success`, and `Result::Failure` subtypes respectively, so in order to access
them value of type `Result` should be downcasted first:

```ruby
result = Result::Success[String, Integer].new(10)
value = case result
when Result::Success
  try.success
else
  nil
end
value # 10

result = Result::Failure[String, Integer].new("Error")
value = case result
when Result::Failure
  result.failure
when
  nil
end
value # "Error"
```

Success and failure values can be retrieved via methods `#success_or` and `#failure_or` as well. These methods
receives fallback values:

```ruby
Result::Success[String, Integer].new(10).success_or(0) # 10
Result::Success[String, Integer].new(10).failure_or("Error") # "Error"

Result::Failure[String, Integer].new("Error").success_or(0) # 0
Result::Failure[String, Integer].new("Error").failure_or("Another Error") # "Error"
```

### Methods

#### `#to_dry`

Converts an instance of a monad in to an instance of corresponding dry-monad.

```ruby
Result::Success[String, Integer].new(10).to_dry      # Success(10): Dry::Monads::Result::Success
Result::Failure[String, Integer].new("Error").to_dry # Failure("Error"): Dry::Monads::Result::Failure
```


#### `.from_dry`

Converts instance of `Dry::Monads::Result` into instance `Mayak::Monads::Result`

```ruby
sig { returns(Dry::Monads::Result::Success[String, Integer]) }
def dry_success
  Dry::Monads::Result::Success.new(10)
end

sig { returns(Dry::Monads::Result::Success[String, Integer]) }
def dry_failure
  Dry::Monads::Result::Failure.new("Error")
end

Try.from_dry(dry_success) # Mayak::Monads::Result::Success[String, Integer](value = 10)
Try.from_dry(dry_failure) # Mayak::Monads::Result::Success[String, Integer]("Error")
```

Unfortunately `.from_dry` doesn't preserve types due to the way `Dry::Monads::Try` is written, so
this method always returns `Mayak::Monads::Try[T.untyped]`.

#### `#map`

The same as `fmap` in a dry-monads `Result`. Allows to modify the value with a block if it's present.

```ruby
sig { returns(Result[String, Integer]) }
def success
  Result::Success[String, Integer].new(10)
end

sig { returns(Result[String, Integer]) }
def failure
  Result::Failure[String, Integer].new("Error")
end

success.map { |a| a + 20 } # Result::Success[Integer](value = 20)
failure.map { |a| a + 20 } # Result::Failure[Integer](error=#<StandardError: Error>)
```

#### `#flat_map`

The same as `bind` in a dry-monads `Result`. Allows to modify the value with a block that returns another `Result`
if it's a `Result::Success`, otherwise returns `Result::Failure`. If the block returns `Result::Failure`, the whole computation returns `Result::Failure`.

```ruby
sig { params(a: Integer, b: Integer).returns(Mayak::Monads::Result[String, Integer]) }
def divide(a, b)
  if a == 0
    Result::Failure[String, Integer].new("Division by zero")
  else
    Result::Success[String, Integer].new(a / b)
  end
end

divide(20, 2).flat_map { |a| divide(a, 2) } # Result::Success[String, Integer](value = 5)
divide(20, 2).flat_map { |a| divide(a, 0) } # Result::Failure[String, Integer](@failure="Division by zero")
divide(20, 0).flat_map { |a| divide(a, 2) } # Result::Failure[String, Integer](@failure="Division by zero")
```

#### `#filter_or`

Receives a block the returns a boolean value and checks the underlying value with the block when a monad is `Result::Success`.
Returns `Result::Failure` with provided error if the block called on the value returns `false`, and returns `self` if the block returns `true`.
Returns self if the original monad is `Result::Failure`.

```ruby
divide(10, 2).filter_or("Above 5") { |value| value <= 5 } # Result::Success[String, Integer](value = 5)
divide(20, 2).filter_or("Above 5") { |value| value <= 5 } # Result::Failure[String, Integer](@failure="Above 5")
divide(10, 0).filter_or("Above 5") { |value| value <= 5 } # Result::Failure[String, Integer](@failure="Division by zero")
```

#### `#success?`

Returns true if a `Result` is a `Result::Success` and false if it's a `Result::Failure`.

```ruby
divide(20, 2).success? # true
divide(20, 0).success? # false
```

#### `#failure?`

Returns true if a `Result` is a `Result::Failure` and false if it's a `Result::Success`.

```ruby
divide(20, 2).failure? # false
divide(20, 0).failure? # true
```

#### `#success_or`

Unpack a `Result` and returns its success value if it's a `Result::Success`, or returns provided fallback value if it's a `Result::Failure`.

```ruby
divide(20, 2).value_or(0) # 10
divide(20, 0).value_or(0) # 0
```

#### `#failure_or`

Unpack a `Result` and returns its error if it's a `Result::Failure`,
or returns provided fallback error of `StandardError` subtype if it's a `Success`.

```ruby
divide(20, 2).failure_or("Error") # "Error"
divide(20, 0).failure_or("Error") # "Division by zero"
```

#### `#flip`

Flips failure and success channels, converting `Result[A, B]` into `Result[B, A]`.
Basically, transforms `Success` into `Failure` and vice versa.


```ruby
divide(10, 2).flip # Result::Failure[Integer, String](value = 5)
divide(10, 0).flip # Result::Success[Integer, String](value = "Division by zero")
```

#### `#either`

Receives two functions: one from an error to a result
value (failure function), and another one from successful value to a result value (success function).
If a `Result` is an instance of `Result::Success`, applies success function to a success value,
otherwise applies error function to an error. Note that both functions must have the same return type.

```ruby
divide(10, 2).either(
  -> (error) { "Error occurred: `#{error}`" },
  -> (value) { value.to_s }
) # 5

divide(10, 0).either(
  -> (error) { "Error occurred: #{error}" },
  -> (value) { value.to_s }
) # Error occurred: `Division by zero`
```

#### `#tee`

If a `Result` is an instance of `Result::Success`, runs a block with a value of `Result::Success` passed, and returns the monad itself
unchanged. Doesn't do anything if the monad is an instance of `Result::Failure`.

```ruby
divide(10, 2).tee { |a| puts a }
# returns: Result::Success[String, Integer](value=5)
# console: 5

divide(10, 0).tee { |a| puts a }
# returns: Result::Failure[String, Integer](@failure="Division by zero")
```

#### `#map_failure`

Transforms an error with a block if a monad is `Failure`. Returns itself otherwise. Note that the passed block
should return an instance of `StandardError`, or an instance of a subtype of the `StandardError`.

```ruby
divide(10, 0).map_failure { |error| "Error occurred: `#{error}`" } # Result::Failure[String, Integer](@failure="Error occurred: `Division by zero`")
divide(10, 2).map_failure { |error| "Error occurred: `#{error}`" } # Result::Success[String, Integer](@value=5)
```

#### `#flat_map_failure`

Transforms an error with a block that returns an instance of `Result` if a monad is `Result::Failure`. Returns itself otherwise.
Allows to recover from error with a computation, that can fail too.

```ruby
divide(10, 2).flat_map_failure { |_error|
  Result::Success[String, Integer].new(0)
} # Result::Success[String, Integer](@value=5)

divide(10, 2).flat_map_failure { |error|
  Result::Failure[String, Integer].new("Error")
} # Result::Success[String, Integer](@value=2)

divide(10, 0).flat_map_failure { |error|
  Result::Success[String, Integer].new(0)
} # Result::Success[String, Integer](@value=0)

divide(10, 0).flat_map_failure { |error|
  Result::Success[String, Integer].new("Error")
} # Result::Failure[String, Integer](@failure="Error")
```

#### `#to_task`

Converts a value to task. Receives a block that converts an error into an instance of `StandardError`.
If a `Result` is an instance of `Result::Success`, it returns succeeded task.
If it's a `Result::Failure`, it returns failed task with an `Failure`'s error returned by the block.

```ruby
task = Mayak::Concurrent::Task.execute { 100 }

task.flat_map { |value|
  divide(value, 10).to_task { |error| StandardError.new(error) }
}.await! # 10

task.flat_map { |value|
  divide(value, 0).to_task { |error| StandardError.new(error) }
}.await!  # StandardError: Divison by zero
```

#### `#to_try`

Converts a `Result` into a `Try`. Receives a block that converts an error into an instance of `StandardError`.
If the `Result` is a `Result::Success`, returns `Try::Success` with a success value.
If it's a `Result::Failure`, returns `Try::Failre` with a an error value returned by the block.

```ruby
divide(10, 2).to_result { |error| StandardError.new(error) } # Try::Success[Integer](value = 5)
divide(10, 0).to_result { |error| StandardError.new(error) } # Try::Failure[Integer](error = #<ZeroDivisionError: divided by 0>)
```

#### `#to_maybe`

Converts a `Result` value to `Maybe`. When the `Result` instance is a `Result::Success`, returns `Maybe` containing successful value.
When the `Result` is an instance of `Result::Failure`, returns `None`. Note that during the transformation error is lost.

```ruby
divide(10, 2).to_maybe # Some[Integer](value = 5)
divide(10, 0).to_maybe # None[Integer]
```

#### `#as`

Substitutes successful value in `Result::Success` with a new value, if the monad is instance of `Result::Failure`, returns
the monad unchanged.

```ruby
divide(10, 2).as("Success") # Result::Success[String, String](@value="Success")
divide(10, 0).as("Success") # Result::Failure[String, String](@failure="Division by zero")
```

#### `#failure_as`

Substitutes an error `Result::Failure` with a new error, if the monad is instance of `Try::Success`, returns
the monad unchanged.

```ruby
divide(10, 2).failure_as(0) # Result::Success[Integer, Integer](@value=5)
divide(10, 0).failure_as(0) # Result::Failure[Integer, Integer](@failure=0)
```

#### `#recover`

Converts `Result::Failure` into a `Result::Success` with a provided value. If the monad is an instance of `Result::Success`, returns itself.
Basically, recovers from an error with a successful value.

```ruby
divide(10, 2).recover(0) # Result::Success[String, Integer](value = 5)
divide(10, 0).recover(0) # Result::Success[Integer](value = 5)
```

#### `#recover_with`

Receives a block that converts an error into successful value, and converts `Failure` into a `Success` with the value.
If the monad is an instance of `Success`, returns itself.Basically, recovers from an error with a successful value.

```ruby
divide(10, 2).recover_with { |error|
  if error == "Division by zero"
    0
  else
    -1
  end
} # Result::Success[String, Integer](value = 5)
divide(10, 2).recover_with { |error|
  if error == "Division by zero"
    0
  else
    -1
  end
} # Result::Success[Integer](value = 0)
```

#### `#recover_with_result`

Alias for `#flat_map_failure`.

#### `.sequence`
`Result.sequence` takes an array of `Result`s and transform it into a `Result` of an array.
If all elements of the array is `Result::Success`, then the method returns `Result::Sucess` containing array of values,
otherwise the method returns `Result::Failure` containing first error.

```ruby
include Mayak::Monads

values = [
  Result::Success[String, Integer].new(1),
  Result::Success[String, Integer].new(2),
  Result::Success[String, Integer].new(3)
]
Result.sequence(values) # Result::Success[String, T::Array[Integer]](@value=[1, 2, 3])

values = [
  Result::Success[String, Integer].new(1),
  Result::Failure[String, Integer].new("Error1"),
  Result::Failure[String, Integer].new("Error2")
]
Result.sequence(values) # Result::Failure[String, Integer](@failure="Error")
```

### Do-notation

`Result` monad does not supports do-notation. The fact that `Result` has two type-parameters makes
it not possible to implement type-safe do-notation in the same fashion as it done for `Maybe` and `Try`.
