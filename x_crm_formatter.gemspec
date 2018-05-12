Gem::Specification.new do |spec|
  spec.name               = "crm_formatter"
  spec.version            = "0.0.1"
  spec.default_executable = "crm_formatter"
  spec.license       = "MIT"
  spec.required_rubygems_version = Gem::Requirement.new(">= 0") if spec.respond_to? :required_rubygems_version=
  spec.authors = ["Adam Booth"]
  spec.date = %q{2018-05-12}
  spec.description = %q{Formats addresses, phones, emails, urls}
  spec.email = %q{4rlm@protonmail.ch}
  spec.files = ["Rakefile", "lib/crm_formatter.rb", "lib/crm_formatter/translator.rb", "bin/crm_formatter"]
  spec.test_files = ["test/test_crm_formatter.rb"]
  spec.homepage = %q{http://rubygems.org/gems/crm_formatter}
  spec.require_paths = ["lib"]
  spec.rubygems_version = %q{1.6.2}
  spec.summary = %q{crm_formatter!}

  if spec.respond_to? :specification_version then
    spec.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
