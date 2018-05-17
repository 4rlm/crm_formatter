# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crm_formatter/version'

Gem::Specification.new do |s|
  s.name          = "crm_formatter"
  s.version       = CRMFormatter::VERSION
  s.authors       = ["Adam Booth"]
  s.email         = ["4rlm@protonmail.ch"]

  s.summary       = %q{Reformat and Normalize CRM Contact Data, Addresses, Phones, Emails and URLs}
  s.description   = %q{Reformat and Normalize CRM Contact Data, Addresses, Phones, Emails and URLs.  Originally developed for proprietary use in an enterprise software suite.  Recently decided to make them open source in a gem.  It's a work in progress as there are additional features being added in near future.  Also creating additonal gems with similar CRM office efficiency objectives.  Please contact me if you have any questions or comments.}
  s.homepage      = "https://github.com/4rlm/crm_formatter"
  s.license       = "MIT"

  # s.files         = `git ls-files -z`.split("\x0").reject do |f|
  #   f.match(%r{^(test|s|features)/})
  # end

  s.require_paths = ["lib"]
  s.files         = Dir.glob("lib/**/*.rb")
  s.files         += ["README.md", "Gemfile", Rakefile]

  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }

  s.required_ruby_version = ">= 2.3.0"
  s.add_dependency 'actionpack', '>= 3.0'
  s.add_dependency 'activerecord', '>= 3.0'
  s.add_dependency 'activesupport', '>= 3.0'
  s.add_dependency 'i18n'
  s.add_dependency 'polyamorous', '~> 1.3.2'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'machinist', '~> 1.0.6'
  s.add_development_dependency 'faker', '~> 0.9.5'
  s.add_development_dependency 'sqlite3', '~> 1.3.3'
  s.add_development_dependency 'pg', '~> 0.21'
  s.add_development_dependency 'mysql2', '0.3.20'
  s.add_development_dependency 'pry', '0.10'

end
