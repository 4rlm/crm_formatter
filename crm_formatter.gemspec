
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crm_formatter'
require "crm_formatter/version"

Gem::Specification.new do |spec|
  spec.name          = "crm_formatter"
  spec.version       = CrmFormatter::VERSION
  spec.authors       = ["Adam Booth"]
  spec.email         = ["4rlm@protonmail.ch"]
  spec.homepage      = "https://github.com/4rlm/crm_formatter"
  spec.license       = "MIT"

  spec.summary       = %q{Reformat, Normalize, and Scrub CRM Contact Data, Addresses, Phones and URLs}
  spec.description   = %q{Reformat, Normalize, and Scrub CRM Contact Data, Addresses, Phones and URLs. Originally developed for proprietary use in an enterprise software suite.  Recently decided to make them open source in a gem.  It's a work in progress as there are additional features being added in near future.  Also creating additonal gems with similar CRM office efficiency objectives.  Please contact me if you have any questions or comments.}

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "rubygems.org"
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
  # spec.post_install_message = "Thanks for installing!"

  spec.required_ruby_version = '~> 2.5.1'
  spec.add_dependency "activesupport", "~> 5.2.0"
  # spec.add_dependency "activesupport-inflector", ['~> 0.1.0']
  # spec.executables << 'rake', '~> 10.4.2'
  spec.extra_rdoc_files = ['README', 'doc/user-guide.txt']

  # spec.add_runtime_dependency 'library', '~> 2.2'
  # spec.add_dependency "activesupport-inflector", ['~> 0.1.0']
  # spec.add_dependency 'activesupport', '>= 3.0'
  # spec.add_dependency 'activerecord', '>= 3.0'
  # spec.required_ruby_version = ">= 2.3.0"
  # spec.add_dependency 'actionpack', '>= 3.0'
  # spec.add_dependency 'i18n'
  # spec.add_dependency 'polyamorous', '~> 1.3.2'
  # spec.add_development_dependency 'rspec', '~> 3'
  # spec.add_development_dependency 'machinist', '~> 1.0.6'
  # spec.add_development_dependency 'faker', '~> 0.9.5'
  # spec.add_development_dependency 'sqlite3', '~> 1.3.3'
  # spec.add_development_dependency 'pg', '~> 0.21'
  # spec.add_development_dependency 'mysql2', '0.3.20'
  # spec.add_development_dependency 'pry', '0.10'

  spec.add_development_dependency "bundler", ">= 1.14.0"
  spec.add_development_dependency "rake", '>= 11.5.1'
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "irbtools"
  # spec.add_development_dependency "pry", "~> 0.11.3"

  # spec.requirements << 'libmagick, v6.0'
  # spec.requirements << 'A good graphics card'


  # # This gem will work with 1.8.6 or greater...
  # spec.required_ruby_version = '>= 1.8.6'
  #
  # # Only with ruby 2.0.x
  # spec.required_ruby_version = '~> 2.0'
  #
  # # Only with ruby between 2.2.0 and 2.2.2
  # spec.required_ruby_version = ['>= 2.2.0', '< 2.2.3']

end
