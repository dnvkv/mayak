# Caching

Caching modules constist from `Mayak::Cache` and several implementations in `Mayak::Caching` module. `Mayak::Caching` provides in-memory caches using regular ruby hashes: an unbounded cache and a cache using LRU eviction policy.

Usage of unbounded cache:
```ruby
unbounded_cache = Mayak::Caching::UnboundedCache[String, Integer].new
unbounded_cache.write("foo", 10)
unbounded_cache.write("bar", 20)

unbounded_cache.read("foo") # 10
unbounded_cache.read("bar") # 20
unbounded_cache.read("baz") # nil

unbounded_cache.delete("bar")
unbounded_cache.read("bar") # nil

unbounded_cache.fetch("foo") { 100 } # 10
unbounded_cache.fetch("bar") { 100 } # 100
unbounded_cache.fetch("bar") { 200 } # 100

unbounded_cache.clear # 100
unbounded_cache.read("foo") # nil
unbounded_cache.read("bar") # nil
```

LRU cache has limited size: when the cache is full and a new element is added, some element is evicted using least recently used policy:

```ruby
lru_cache = Mayak::Caching::LRUCache[String, Integer].new(max_size: 3)

lru_cache.write("key1", 1)
lru_cache.write("key2", 2)
lru_cache.write("key3", 3)

lru_cache.read("key1") # 1
lru_cache.read("key2") # 2
lru_cache.read("key3") # 3

lru_cache.write("key4", 4)
lru_cache.read("key4") # 4
lru_cache.read("key1") # nil
```

You can implement `Mayak::Cache` interface using a different store (for example default Rails cache) and use different implementations interchangeably:

```ruby
class RailsCache < T::Struct
  extend T::Sig
  extend T::Generic
  extend T::Helpers

  include Mayak::Cache

  Key   = type_member
  Value = type_member

  const :converter, T.proc.params(value: T.untyped).returns(Value)

  sig { override.params(key: Key).returns(T.nilable(Value)) }
  def read(key)
    converter.call(Rails.cache.read(key))
  end

  sig { override.params(key: Key, value: Value).void }
  def write(key, value)
    Rails.cache.write(key, value)
  end

  sig { override.params(key: Key, blk: T.proc.returns(Value)).returns(Value) }
  def fetch(key, &blk)
    converter.call(Rails.cache.fetch(key, &blk))
  end

  sig { override.void }
  def clear
    Rails.cache.clear
  end

  sig { override.params(key: Key).void }
  def delete(key)
    Rails.cache.delete(key)
  end
end

class Service < T::Struct
  extend T::Sig

  const :cache, Mayak::Cache[String, String]
end

in_memory = Service.new(
  cache: Mayak::Caching::UnboundedCache[String, String].new
)
rails_cache = Service.new(
  cache: RailsCache[String, String].new(
    converter: -> (value) { value.to_s }
  )
)
```