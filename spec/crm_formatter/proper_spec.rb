# frozen_string_literal: true

# rspec spec/crm_formatter/proper_spec.rb
require 'spec_helper'

describe 'Proper' do
  let(:tool_obj) { CrmFormatter::Proper.new }

  describe '#format_proper' do
    let(:str_in) { '123 bmw-world' }
    let(:hsh_out) do
      {
        :proper_status=>"formatted",
        :proper=>"123 bmw-world",
        :proper_f=>"123 BMW-World"
      }
    end

    it 'format_proper' do
      expect(tool_obj.format_proper(str_in)).to eql(hsh_out)
    end
  end

  describe '#check_proper_status' do
    let(:hsh_in) do
      {
        :proper_status=>nil,
        :proper=>"123 bmw-world",
        :proper_f=>"123 BMW-World"
      }
    end

    let(:hsh_out) do
      {
        :proper_status=>"formatted",
        :proper=>"123 bmw-world",
        :proper_f=>"123 BMW-World"
      }
    end

    it 'check_proper_status' do
      expect(tool_obj.check_proper_status(hsh_in)).to eql(hsh_out)
    end
  end


end
