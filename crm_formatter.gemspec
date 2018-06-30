
# frozen_string_literal: false

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crm_formatter'
require 'crm_formatter/version'

Gem::Specification.new do |spec|
  spec.name          = 'crm_formatter'
  spec.version       = CrmFormatter::VERSION
  spec.authors       = ['Adam Booth']
  spec.email         = ['4rlm@protonmail.ch']
  spec.homepage      = 'https://github.com/4rlm/crm_formatter'
  spec.license       = 'MIT'

  spec.summary       = 'Reformat and Normalize CRM Contact Data, Addresses, Phones and URLs.'
  spec.description   = "CrmFormatter is perfect for curating high-volume enterprise-scale web scraping, and integrates well with Nokogiri, Mechanize, and asynchronous jobs via Delayed_job or SideKick, to name a few.  Web Scraping and Harvesting often gathers a lot of junk to sift through; presenting unexpected edge cases around each corner.  CrmFormatter has been developed and refined during the past few years to focus on improving that task.\n It's also perfect for processing API data, Web Forms, and routine DB normalizing and scrubbing processes.  Not only does it reformat Address, Phone, and Web data, it can also accept lists to scrub against, then providing detailed reports about how each piece of data compares with your criteria lists."

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.5.1'
  spec.add_dependency 'activesupport', '~> 5.0', '>= 5.2'
  # spec.add_dependency 'utf8_sanitizer', '~> 2.14'
  # spec.add_dependency 'utf8_sanitizer'

  # spec.add_dependency "activesupport-inflector", ['~> 0.1.0']
  spec.add_development_dependency 'bundler', '~> 1.16', '>= 1.16.2'
  spec.add_development_dependency 'pry', '~> 0.11.3'
  spec.add_development_dependency 'rake', '~> 12.3', '>= 12.3.1'
  spec.add_development_dependency 'rspec', '~> 3.7'
  # spec.add_development_dependency 'byebug', '~> 10.0', '>= 10.0.2'
  # spec.add_development_dependency 'class_indexer', '~> 0.3.0'
  # spec.add_development_dependency 'irbtools', '~> 2.2', '>= 2.2.1'
  # spec.add_development_dependency 'rubocop', '~> 0.56.0'
  # spec.add_development_dependency 'ruby-beautify', '~> 0.97.4'
  # spec.add_runtime_dependency 'library', '~> 2.2'
  # spec.add_dependency 'activerecord', '>= 3.0'
  # spec.add_dependency 'actionpack', '>= 3.0'
  # spec.add_dependency 'polyamorous', '~> 1.3.2'
  # spec.add_development_dependency 'machinist', '~> 1.0.6'
  # spec.add_development_dependency 'faker', '~> 0.9.5'
  # spec.add_development_dependency 'sqlite3', '~> 1.3.3'
  # spec.add_development_dependency 'pg', '~> 0.21'
  # spec.add_development_dependency 'mysql2', '0.3.20'

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
