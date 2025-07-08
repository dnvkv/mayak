# Http

This module contains abstraction for HTTP interactions. It provides data classes that models HTTP requests and response as well interfaces for http client and codecs.

#### Verb

Enumaration that encodes an HTTP verb.

```ruby
get_verb     = Mayak::Http::Verb::Get
post_verb    = Mayak::Http::Verb::Post
head_verb    = Mayak::Http::Verb::Head
put_verb     = Mayak::Http::Verb::Put
patch_verb   = Mayak::Http::Verb::Patch
delete_verb  = Mayak::Http::Verb::Delete
connect_verb = Mayak::Http::Verb::Connect
options_verb = Mayak::Http::Verb::Options
trace_verb   = Mayak::Http::Verb::Trace
```

#### Request

`Mayak::Http::Request` is a datastructure that encodes an HTTP request.
```ruby
# to build an HTTP request verb and URI should be provided, as well as optional headers hash and body
request = Mayak::Http::Request.new(
  verb:     Mayak::Http::Verb::Put,
  url:      URI.parse("https://www.foobar.com/users/update"),
  headers:  { "content-type" => "application/json" },
  body:     """{ id: 100, name: "Daniil" })"""
)

# to build request helper constructor methods can be used
get_request = Mayak::Http::Request.get(url: URI.parse("https://www.foobar.com"))
```

#### Response

`Mayak::Http::Response` is a datastructure that encodes an HTTP request. It contains status, and optional headers and body:

```ruby
response = Mayak::Http::Response.new(
  status:  200
  headers: { "content-type" => "application/json" },
  body:     """{ id: 100, name: "Daniil" }"""
)
```

#### Client

Interface that encodes an HTTP client. The interface is very simple and consists from one method that receives a request and returns a `Try` monad containg response:
```ruby
module Mayak
  module Http
    module Client
      extend T::Sig
      extend T::Generic

      interface!

      sig { abstract.params(request: Http::Request).returns(Mayak::Monads::Try[Mayak::Http::Response]) }
      def send_request(request)
      end
    end
  end
end
```

You can implement this interface using a specific library:

```ruby
class FaradayClient
  extend T::Sig

  include Mayak::Http::Client

  include Mayak::Monads::Try::Mixin

  sig { params(config_blk: T.nilable(T.proc.params(connection: Faraday::Connection).void)).void }
  def initialize(&config_blk)
    @faraday_instance = T.let(
      config_blk.nil? ? Faraday.new : Faraday.new(&@config_blk),
      Faraday
    )
  end

  sig { override.params(request: Mayak::Http::Request).returns(Mayak::Monads::Try[Mayak::Http::Response]) }
  def send_request(request)
    Try do
      faraday_response = @faraday_instance.run_request(
        verb.serialize.downcase.to_sym,
        request.url,
        request.body,
        request.headers
      )

      Mayak::Http::Response.new(
        status:  T.must(faraday_response.status.to_i),
        headers: faraday_response.headers || {},
        body:    faraday_response.body || ""
      )
    end
  end
end
```