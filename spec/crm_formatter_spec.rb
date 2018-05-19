require 'crm_formatter'
require 'spec_helper'

RSpec.describe CrmFormatter do
  it "has a version number" do
    expect(CrmFormatter::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end

  # it "broccoli is gross" do
  #   expect(CrmFormatter::Tools.portray("Broccoli")).to eql("Gross!")
  # end
  #
  # it "anything else is delicious" do
  #   expect(CrmFormatter::Tools.portray("Not Broccoli")).to eql("Delicious!")
  # end
  #
  # it 'generates a random title' do
  #   title = CrmFormatter.generate_title
  #   title_array = title.split
  #
  #   expect(title_array.length).to eq 3
  # end

end
