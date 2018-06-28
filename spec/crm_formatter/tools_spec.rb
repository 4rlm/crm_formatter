# frozen_string_literal: true

# rspec spec/crm_formatter/tools_spec.rb
require 'spec_helper'

describe 'Tools' do
  let(:tool_obj) { CrmFormatter::Tools.new }
  # before { utf_obj.headers = headers }

  describe '#letter_case_check' do
    let(:str_in) { '123 bmw-world' }
    let(:str_out) { '123 BMW-World' }

    it 'letter_case_check' do
      expect(tool_obj.letter_case_check(str_in)).to eql(str_out)
    end
  end


  describe '#capitalize_dashes' do
    let(:str_in) { '123 Bmw-world' }
    let(:str_out) { '123 Bmw-World' }

    it 'capitalize_dashes' do
      expect(tool_obj.capitalize_dashes(str_in)).to eql(str_out)
    end
  end

  describe '#check_for_brands' do
    let(:str_in) { '123 Bmw-World' }
    let(:str_out) { '123 BMW-World' }

    it 'check_for_brands' do
      expect(tool_obj.check_for_brands(str_in)).to eql(str_out)
    end
  end
end
