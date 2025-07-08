[gem]: https://rubygems.org/gems/mayak
[actions]: https://github.com/dnvkv/mayak/actions

# Mayak [![Gem Version](https://badge.fury.io/rb/mayak.svg)][gem] [![CI Status](https://github.com/dnvkv/mayak/actions/workflows/ci.yml/badge.svg)][actions]

### Overview

Mayak is a library which aims to provide abstractions for well typed programming in Ruby using Sorbet type checker. Mayak provides generic interfaces and utility classes for various applications, and as a foundation for other libraries.

### Installation

In order to use the library, add the following line to your `Gemfile`:

```ruby
gem "mayak"
```
or install it via the following command:
```ruby
gem install "mayak"
```

If you are using tapioca, add following line into tapioca's `require.rb` before generating rbi's for the gem:

```ruby
require "mayak"
```

### Documentation

Mayak consists from separate classes and interfaces as well as separate modules for specific domains.

* [Caching](./docs/caching.md)
* [Monads](./docs/monads.md)
* [HTTP](./docs/http.md)
* [Lazy](./docs/lazy.md)
* [Functions](./docs/function.md)

#### Miscellaneous

##### JSON

`JSON` module provides a type alias to encode JSON type:

```ruby
JsonType = T.type_alias {
  T.any(
    T::Array[T.untyped],
    T::Hash[T.untyped, T.untyped],
    String,
    Integer,
    Float
  )
}
```

and methods to safely parse JSON:

```ruby
Mayak::Json.parse(%{ { "foo": 1} })
#<Mayak::Monads::Try::Success:0x00000001086c8398 @value={"foo"=>1}>

Mayak::Json.parse(%{ { "foo: 1} })
#<Mayak::Monads::Try::Failure:0x00000001085ea250 @failure=#<Mayak::Json::ParsingError: unexpected token at '{ "foo: 1} '>>
```

##### Numeric

`Numeric` method provides method for safe parsing numerical values:

```ruby
Mayak::Numeric.parse_float("0.1")
#<Mayak::Monads::Maybe::Some:0x000000010bbb4070 @value=0.1>

Mayak::Numeric.parse_float("0.1sdfs")
#<Mayak::Monads::Maybe::None:0x000000010bab3e50>

Mayak::Numeric.parse_integer("10")
#<Mayak::Monads::Maybe::Some:0x0000000108fcdb78 @value=10>

Mayak::Numeric.parse_integer("10qq")
#<Mayak::Monads::Maybe::None:0x000000010bbf64c0>

Mayak::Numeric.parse_decimal("100")
#<Mayak::Monads::Maybe::Some:0x000000010ba78968 @value=0.1e3>

Mayak::Numeric.parse_decimal("100dd")
#<Mayak::Monads::Maybe::None:0x000000010bb718b0>
```

##### Random

Utils for random number generating

###### `#jittered`

Adds random noise for a number within specified range

```ruby
# Yield a random number from 100 to 105
Mayak::Random.jittered(100, jitter: 0.05)
# 101.53359412200601

Mayak::Random.jittered(100, jitter: 0.05)
# 103.59043964431787
```

##### WeakRef

Parameterized weak Reference class that allows a referenced object to be garbage-collected.

```ruby
class Obj
end

value = Obj.new
value = Mayak::WeakRef[Obj].new(value)
value.deref
#<Mayak::Monads::Maybe::Some:0x0000000103e8fa90 @value=#<Obj:0x000000010721de48>>

GC.start
value.deref
#<Mayak::Monads::Maybe::None:0x000000010715f6f0>
# Not necessarily will be collected after only one GC cycle
```