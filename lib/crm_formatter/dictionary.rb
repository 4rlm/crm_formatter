module CrmFormatter
  module Dictionary

    def self.dict_page
      msg = 'welcome to dicts!'
      binding.pry
      msg
    end

  DICTIONARY = { pronouns: ["A", "The", "Their", "Some", "None"], adjectives: ["a really long list I won't reproduce here"], nouns: ["another really long list I won't reproduce here"]}

  def Dictionary.pronoun
   DICTIONARY[:pronouns].sample
  end

  def Dictionary.adjective
   DICTIONARY[:adjectives].sample
  end

  def Dictionary.noun
   DICTIONARY[:nouns].sample
  end

  end
end
