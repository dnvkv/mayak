# lib = File.expand_path("lib", __dir__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# require "mayak/version"

Gem::Specification.new do |spec|
  spec.name          = "mayak"
  spec.version       = "0.2.7"
  spec.summary       = "Set of fully typed utility classes and interfaces integrated with Sorbet."
  spec.description   = spec.summary
  spec.authors       = ["Daniil Bober"]
  spec.files         = Dir["CHANGELOG.md", "LICENSE", "README.md", "mayak.gemspec", "lib/**/*", "rbi/**/*"]
  spec.license       = "MIT"
  spec.executables   = []
  spec.require_paths = ["lib", "rbi"]

  spec.add_dependency 'sorbet-runtime'
  spec.add_dependency 'sorbet'
  spec.add_dependency 'sorbet-coerce'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "tapioca"
end