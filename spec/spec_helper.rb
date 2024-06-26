$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "mayak"
require "pathname"

SPEC_ROOT = Pathname(__FILE__).dirname

begin
  require "pry"
  require "pry-byebug"
rescue LoadError
end

$VERBOSE = true

Dir["./spec/shared/**/*.rb"].sort.each { |f| require f }

module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    result
  end
end