# frozen_string_literal: true

# rspec spec/crm_formatter/tools_spec.rb
require 'spec_helper'

describe 'Tools' do
  let(:tool_obj) { CrmFormatter::Tools.new }

  describe '#letter_case_check' do
    let(:str_in) { 'the gmc and bmw-world of AUSTIN tx' }
    let(:str_out) { 'The GMC and BMW-World of Austin TX' }

    it 'letter_case_check' do
      expect(tool_obj.letter_case_check(str_in)).to eql(str_out)
    end
  end

  describe '#force_capitalize' do
    let(:str_in) { 'the gmc and bmw-world of AUSTIN tx' }
    let(:str_out) { 'The Gmc And Bmw-world Of Austin Tx' }

    it 'force_capitalize' do
      expect(tool_obj.force_capitalize(str_in)).to eql(str_out)
    end
  end

  describe '#capitalize_dashes' do
    let(:str_in) { 'The Gmc And Bmw-world Of Austin Tx' }
    let(:str_out) { 'The Gmc And Bmw-World Of Austin Tx' }

    it 'capitalize_dashes' do
      expect(tool_obj.capitalize_dashes(str_in)).to eql(str_out)
    end
  end

  describe '#force_upcase' do
    let(:str_in) { 'The Gmc And Bmw-World Of Austin Tx' }
    let(:str_out) { 'The GMC And BMW-World Of Austin TX' }

    it 'force_upcase' do
      expect(tool_obj.force_upcase(str_in)).to eql(str_out)
    end
  end

  describe '#force_downcase' do
    let(:str_in) { 'The GMC And BMW-World Of Austin TX' }
    let(:str_out) { 'the GMC and BMW-World of Austin TX' }

    it 'force_downcase' do
      expect(tool_obj.force_downcase(str_in)).to eql(str_out)
    end
  end

  describe '#force_first_cap' do
    let(:str_in) { 'the GMC and BMW-World of Austin TX' }
    let(:str_out) { 'The GMC and BMW-World of Austin TX' }

    it 'force_first_cap' do
      expect(tool_obj.force_first_cap(str_in)).to eql(str_out)
    end
  end

  describe '#add_space' do
    let(:str_in) { 'Hot-Deal Auto Insurance' }
    let(:str_out) { ' Hot-Deal Auto Insurance ' }

    it 'add_space' do
      expect(tool_obj.add_space(str_in)).to eql(str_out)
    end
  end

  describe '#strip_squeeze' do
    let(:str_in) { ' Hot-Deal Auto Insurance ' }
    let(:str_out) { 'Hot-Deal Auto Insurance' }

    it 'strip_squeeze' do
      expect(tool_obj.strip_squeeze(str_in)).to eql(str_out)
    end
  end

end
