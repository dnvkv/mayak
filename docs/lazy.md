# Lazy

`Lazy` classs represents a value that evaluates only during it's access, and evaluates only once
during the first access. Basically, `Lazy` wraps a block of code (thunk) that returns a value (`Lazy` has single type parameter of a value), and executes only when the value accessed for the first time
and then stores it afterward.

In order to build `Lazy` a type parameter of value holded should be provided as well as a block that computes a value of the type.
Note that the block is not executed right away.

```ruby
lazy1 = ::Mayak::Lazy[Integer].new { 1 }

buffer = []
lazy2 = ::Mayak::Lazy[Integer].new do
  buffer << 1
  1
end
buffer
#> []
```

To access the value call `#value`. If the value is not yet computed, provided block will be executed and its result will be stored. Further invokations
of this method won't execute the block again.

```ruby
buffer = []
lazy = ::Mayak::Lazy[Integer].new do
  buffer << 1
  1
end
buffer
#> []

# Will execute the block and return the computed value.
lazy.value
#> 1
buffer
#> [1]

# Will return the memoized value, but won't call the block again
lazy.value
#> 1
buffer
#> [1]
```

`Lazy` can be used in situations, when we want to inject some dependency into some class or method, but it may not be used, and the computation or aacquisition of the dependency may be cosftul. In this cases, it's acquisitation may be wrapped in lazy.

In more imperative style
```ruby
sig { params(env_variable: String, file_content: ::Mayak::Lazy[String], default: String).returns(String) }
def fetch_config(env_variable, file_content, default)
  from_environment = ENV[env_variable]
  if env.empty?
    file_config = ::Core::Json.parse(file_content.value).success_or({})
    from_file = file_config["configuration"]
    if from_file.empty?
      default
    else
      from_file
    end
  else
    from_environment
  end
end
```

Using Mayak monads:
```ruby
include ::Mayak::Monads::Maybe::Mixin

sig { params(env_variable: String, file_content: ::Mayak::Lazy[String], default: String).returns(String) }
def fetch_config(env_variable, file_content, default)
  Maybe(ENV[env_variable])
    .recover_with_maybe(::Core::Json.parse(file_content.value).to_maybe)
    .flat_map { |json| Maybe(json["configuration"]) }
    .value_or(default)
end
```

This method receives name of environment variable, and file content as lazy value. The method
tries to read the environment variable, and if it's not present and reads the file content to find the configuration.
`Lazy` allows to incapsulate behaviour of reading from file, so it can be passed as dependency, method `#fetch_config` doesn't 
know anything about reading from file, but because of usage of `lazy` we can postpone it's execution thus avoiding unnecessary work.

`Lazy` can be transformed via methods `#map` and `#flat_map`.  

Method `#map` allows to transform value inside `Lazy` without triggering executing. Note that `#map` returns
a new instance without mutating previous `Lazy`.
```ruby
int_lazy = ::Mayak::Lazy[Integer].new do
  puts("On initialize")
  1
end
string_lazy = int_lazy.map do |int|
  puts("On mapping")
  int.to_s
end
int_lazy.value # 1
#> On initialize

string_lazy.value # "1"
#> On initialize
#> On mapping

sig { params(file_content: ::Mayak::Lazy[String]).returns(::Mayak::Lazy[Maybe[String]]) }
def file_content_config(file_content)
  file_content.map do |file_content|
    ::Core::Json
      .parse(file_content.value)
      .to_maybe
      .flat_map { |json| Maybe(json["configuration"]) }
  end
end
```

Method `#flat_map` allows to chain lazy computations. It receives a block, that builds a new `Lazy` value from the value of original
`Lazy` and returns a new instance of `Lazy`.

```ruby
sig { params(env_name: String).returns(::Mayak::Lazy[String]) }
def lazy_env(env_name)
  ::Mayak::Lazy[String].new { ENV[env_name] }
end

env_variable_name = ::Mayak::Lazy[String].new { "VARIABLE" }
env_variable = env_variable_name.flat_map { |env_name| lazy_env(env_name) }
```

This may be useful when want to perform a lazy computation based on result of some other lazy computation without enforcing the evaluation.

For example we have a file that contains list of file names. We can build a lazy computation that read all lines from this code.
```ruby
sig { params(file_name: String).returns(::Mayak::Lazy[T::Array[String]]) }
def read_file_lines(file_name)
  ::Mayak::Lazy[T::Array[String]].new { File.read(file_name).split }
end
```

Let's we want to read all filenames from the root file, and then read the first file lazily. In this cases, the lazy computation can be chained via `#flat_map`:

```ruby
sig { params(file_name: String).returns(::Mayak::Lazy[T::Array[String]]) }
def read_first_file(file_name)
  read_file_lines(file_name).flat_map do |file_names|
    Maybe(file_names.first)
      .filter(&:empty?)
      .map { |file| read_file_lines(file) }
      .value_or(::Mayak::Lazy[T::Array[String]].new { [] })
  end
end
```

In order to combine two lazies of different types into a single one, method `#combine` can be used.
This method receives another lazy (it can be lazy of different type), and a block
and returns a lazy containing result of applying passed blocked to values calculated by lazies.

```ruby
class ConfigFiles < T::Struct
  const :database_config_file, ::File
  const :server_config_file,   ::File
end

sig { returns(::Mayak::Lazy[File]) }
def database_config_file
  ::Mayak::Lazy[File].new { File.new(DATABASE_CONFIG_FILE_NAME, "r") }
end

sig { returns(::Mayak::Lazy[File]) }
def server_config_file
  ::Mayak::Lazy[File].new { File.new(SERVER_CONFIG_FILE_NAME, "r") }
end

sig { returns(::Mayak::Lazy[ConfigFiles]) }
def config_files
  database_config_file.combine(server_config_file) do |db_file, server_file|
    ConfigFiles.new(
      database_config_file: database_config_file,
      server_config_file: server_file
    )
  end
end
```

The same behaviour can be achieved with a method `.combine_two`:

```ruby
sig { returns(::Mayak::Lazy[ConfigFiles]) }
def config_files
  ::Mayak::Lazy.combine_two(database_config_file, server_config_file) do |db_file, server_file|
    ConfigFiles.new(
      database_config_file: database_config_file,
      server_config_file: server_file
    )
  end
end
```

There are also methods `.combine_three`, `.combine_four` upto `.combine_sevel` to combine multiple lazies of diffent types.

If you need to combined multiple lazies containing the same value, you can use `.combine_many`. It works
as `Array#reduce`: receives an array of lazies containing the same type, initial value of result type, and a block
receiving accumulator value of result type, and value of next lazy.

```ruby
sig { returns(::Mayak::Lazy[Integer]) }
def lazy
  ::Mayak::Lazy.combine_many(
    [::Mayak::Lazy[Integer].new(1), ::Mayak::Lazy[Integer].new(2), ::Mayak::Lazy[Integer].new(3)],
    0
  ) { |acc, value| acc + value }
end

lazy.value # 10
```

If you need to transform array of lazies of some value into lazy of array of the value, you can use `.sequence` method.

```ruby
sig { returns(::Mayak::Lazy[T::Array[Integer]]) }
def lazy
  ::Mayak::Lazy.sequence([::Mayak::Lazy[Integer].new(1), ::Mayak::Lazy[Integer].new(2), ::Mayak::Lazy[Integer].new(3)])
end

lazy.value # [1, 2, 3]
```
