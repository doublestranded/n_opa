
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "n_opa/version"

Gem::Specification.new do |spec|
  spec.name          = "n_opa"
  spec.version       = NOpa::VERSION
  spec.authors       = ["Alex Smith"]
  spec.email         = ["saalexantay@gmail.com"]

  spec.summary       = %q{Algorithm for the Order-preserving Assignment Problem without contiguity}
  spec.description   = %q{Algorithm for the Order-preserving Assignment Problem without contiguity}
  spec.homepage      = "https://github.com/doublestranded/n_opa"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-benchmark"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "ruby-prof"
end
