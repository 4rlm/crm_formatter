# frozen_string_literal: true

# Dictionary, Sample Module for Rspec testing setup.
module CrmFormatter
  module Dictionary
    def self.dict_page
      'welcome to dicts!'
    end

    DICTIONARY = { pronouns: %w[A The Their Some None], adjectives: ["a really long list I won't reproduce here"], nouns: ["another really long list I won't reproduce here"] }.freeze

    def self.pronoun
      DICTIONARY[:pronouns].sample
    end

    def self.adjective
      DICTIONARY[:adjectives].sample
    end

    def self.noun
      DICTIONARY[:nouns].sample
    end
  end
end
