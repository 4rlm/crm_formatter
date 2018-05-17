
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crm_formatter'
require "crm_formatter/version"

Gem::Specification.new do |s|
  s.name          = "crm_formatter"
  s.version       = CrmFormatter::VERSION
  s.authors       = ["Adam Booth"]
  s.email         = ["4rlm@protonmail.ch"]
  s.homepage      = "https://github.com/4rlm/crm_formatter"
  s.license       = "MIT"

  s.summary       = %q{Reformat, Normalize, and Scrub CRM Contact Data, Addresses, Phones and URLs}
  s.description   = %q{Reformat, Normalize, and Scrub CRM Contact Data, Addresses, Phones and URLs. Originally developed for proprietary use in an enterprise software suite.  Recently decided to make them open source in a gem.  It's a work in progress as there are additional features being added in near future.  Also creating additonal gems with similar CRM office efficiency objectives.  Please contact me if you have any questions or comments.}

  if s.respond_to?(:metadata)
    s.metadata["allowed_push_host"] = "rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|s|features)/})
  end

  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  # s.required_ruby_version = ">= 2.3.0"
  # s.add_dependency 'actionpack', '>= 3.0'
  # s.add_dependency 'activerecord', '>= 3.0'
  # s.add_dependency 'activesupport', '>= 3.0'
  # s.add_dependency 'i18n'
  # s.add_dependency 'polyamorous', '~> 1.3.2'
  # s.add_development_dependency 'rspec', '~> 3'
  # s.add_development_dependency 'machinist', '~> 1.0.6'
  # s.add_development_dependency 'faker', '~> 0.9.5'
  # s.add_development_dependency 'sqlite3', '~> 1.3.3'
  # s.add_development_dependency 'pg', '~> 0.21'
  # s.add_development_dependency 'mysql2', '0.3.20'
  # s.add_development_dependency 'pry', '0.10'

  # s.add_development_dependency "bundler", "~> 1.16"
  s.add_development_dependency "bundler", "~> 1.9"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.2"
end
