require 'spec_helper'

describe "Dictionary Module" do

  it "generates a randon pronoun" do
    my_pronoun = Dictionary.pronoun

    expect(Dictionary::DICTIONARY[:pronouns]).to include(my_pronoun)
  end

  it "generates a random adjective" do
    my_pronoun = Dictionary.adjective

    expect(Dictionary::DICTIONARY[:adjectives]).to include(my_pronoun)
  end

  it "generates a randon noun" do
    my_pronoun = Dictionary.noun

    expect(Dictionary::DICTIONARY[:nouns]).to include(my_pronoun)
  end

end
