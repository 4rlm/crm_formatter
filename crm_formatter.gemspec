# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crm_formatter/version'

Gem::Specification.new do |spec|
  spec.name          = "crm_formatter"
  spec.version       = CRMFormatter::VERSION
  spec.authors       = ["Adam Booth"]
  spec.email         = ["4rlm@protonmail.ch"]

  spec.summary       = %q{Reformat and Normalize CRM Contact Data, Addresses, Phones, Emails and URLs}
  spec.description   = %q{Reformat and Normalize CRM Contact Data, Addresses, Phones, Emails and URLs.  Originally developed for proprietary use in an enterprise software suite.  Recently decided to make them open source in a gem.  It's a work in progress as there are additional features being added in near future.  Also creating additonal gems with similar CRM office efficiency objectives.  Please contact me if you have any questions or comments.}
  spec.homepage      = "https://github.com/4rlm/crm_formatter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

end
