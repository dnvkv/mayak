# Codecs

Codecs define generic abstractions data for encoding and decoding data.

## Encoder

Encoder is basically a function parameterized with two type parameters `Entity` and `Protocol`, the function encodes a value of `Entity` into a value of `Protocol`. The interface for `Encoder[Entity, Protocol]` has only one method `#encode`:

```ruby
sig { abstract.params(entity: Entity).returns(Protocol) }
def encode(entity)
end
```

The default implementations is built using a function containing implementation of `#encode` method passed as a block:

```ruby
encoder = Mayak::Encoder::Implementation[{ name: String, age: Integer }, String].new do |record|
  JSON.dump(record)
end

encoder.encode([1, 2, 3]) # [1,2,3]
```

## Decoder

Decoder performs an opposite action: it decode a value of `Entity` from instance of `Protocol`. Since not any instance of `Protocol` maybe transformed to a type `Entity`, the function returns `::Mayak::Monads::Try[Entity]`.

```ruby
sig { abstract.params(protocol: Protocol).returns(::Mayak::Monads::Try[Entity]) }
def decode(protocol)
end
```

The default `Decoder` impelementation works in the same way is `Encoder` implementation:

```ruby
decoder = ::Mayak::Decoder::Implementation[String, { name: String, age: Integer }].new do |json|
  Try { JSON.parse(json) }.flat_map do |json|
    if !json["name"].is_a?(String) || !json["age"].is_a?(Integer)
      ::Mayak::Monads::Try::Failure.new(
        StandardError.new("Invalid JSON")
      )
    else
      ::Mayak::Monads::Try::Success.new({ name: json["name"], age: json["age"] })
    end
  end
end

decoder.decode('{ "name": "Daniil", "age": 26 }') # Success({ name: "Daniil", age: 26 })
```

## Codec

The `Codec` interface provides functionality of encoding an `Entity` to a `Protocol` and by decoding `Entity` from the `Protocol` by implementing both `#encode` and `#decode`.

Codec can be built by providing an instances of `encoder` and `decoder` for `Entity` and `Protocol`:

```ruby
codec = ::Mayak::Codec::FromPair[{ name: String, age: Integer }, String].new(
  encoder: encoder, decoder: decoder
)

encoder.encode([1, 2, 3]) # [1,2,3]
decoder.decode('{ "name": "Daniil", "age": 26 }') # Success({ name: "Daniil", age: 26 })
```

Given any arbitratry instance of a codec, it is possible to get instances of respective `Encoder` and `Decoder`.

```ruby
user_codec = T.let(default_user_codec, ::Mayak::Codec[User, String])

encoder = T.let(user_codec.to_encoder, ::Mayak::Encoder[User, String])
decoder = T.let(user_codec.to_decoder, ::Mayak::Decoder[String, User])
```

## Codecs implementation

There are default codec implementation based on `sorbet-coerce`.

For intstance the `JsonCodec::FromHashSerializable` implements a codec for `HashSerializable` and `String` (represents a JSON).
The codec is derived automatically based on a type variable:

```ruby
class User < T::Struct
  include ::Mayak::HashSerializable

  const :name,  String
  const :email, String
  const :age,   Integer

  sig { returns(::Mayak::Codec[User, String]) }
  def self.json_codec
    ::Mayak::JsonCodec::FromHashSerializable[User].new
  end
end

user = User.new(name: "Daniil", email: "example@gmail.com", age: 25)

encoded = User.json_codec.encode(user) # {"name": "Daniil", "email": "example@gmail.com", "age": 25}
User.json_codec.decode(encoded) # Success(User<name="Daniil", email="example@gmail.com", age=25>)
```
