# rspec spec/crm_formatter/phone_spec.rb
require 'spec_helper'

describe 'Phone' do
  # before { utf_obj.headers = headers }
  let(:phone_obj) { CrmFormatter::Phone.new }
  let(:phone_str_in) { '555-457-4391' }
  let(:phone_hsh_out) do
    {
      :phone=>"555-457-4391",
      :phone_f=>"(555) 457-4391",
      :phone_status=>"formatted"
    }
  end

  describe '#validate_phone' do
    it 'validates phone' do
      expect(phone_obj.validate_phone(phone_str_in)).to eql(phone_hsh_out)
    end
  end

  describe '#check_phone_status' do
    let(:phone_hsh_in) do
      {
        :phone=>"555-457-4391",
        :phone_f=>"(555) 457-4391",
        :phone_status=>false
      }
    end

    it 'compares orig and formatted phone' do
      expect(phone_obj.check_phone_status(phone_hsh_in)).to eql(phone_hsh_out)
    end
  end


  describe '#format_phone' do
    let(:phone_str_out) { '(555) 457-4391' }

    it 'formats phone' do
      expect(phone_obj.format_phone(phone_str_in)).to eql(phone_str_out)
    end
  end

end
