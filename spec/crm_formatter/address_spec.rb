# frozen_string_literal: true

# rspec spec/crm_formatter/address_spec.rb
require 'spec_helper'

describe 'Address' do
  let(:adr_obj) { CrmFormatter::Address.new }
  # before { utf_obj.headers = headers }

  describe '#format_full_address' do
    let(:hsh_in) do
      {
        street: '1234 East Fair Boulevard',
        city: 'Austin',
        state: 'Texas',
        zip: '78734'
      }
    end
    let(:hsh_out) do
      {
        street_f: '1234 E Fair Blvd',
        city_f: 'Austin',
        state_f: 'TX',
        zip_f: '78734',
        full_addr: '1234 East Fair Boulevard, Austin, Texas, 78734',
        full_addr_f: '1234 E Fair Blvd, Austin, TX, 78734',
        address_status: 'formatted'
      }
    end

    it 'format_full_address' do
      expect(adr_obj.format_full_address(hsh_in)).to eql(hsh_out)
    end
  end

  describe '#check_addr_status' do
    let(:hsh_in) do
      {
        street_f: '1234 E Fair Blvd',
        city_f: 'Austin',
        state_f: 'TX',
        zip_f: '78734',
        full_addr: '1234 East Fair Boulevard, Austin, Texas, 78734',
        full_addr_f: '1234 E Fair Blvd, Austin, TX, 78734'
      }
    end
    let(:hsh_out) do
      {
        street_f: '1234 E Fair Blvd',
        city_f: 'Austin',
        state_f: 'TX',
        zip_f: '78734',
        full_addr: '1234 East Fair Boulevard, Austin, Texas, 78734',
        full_addr_f: '1234 E Fair Blvd, Austin, TX, 78734',
        address_status: 'formatted'
      }
    end

    it 'check_addr_status' do
      expect(adr_obj.check_addr_status(hsh_in)).to eql(hsh_out)
    end
  end

  describe '#make_full_address_original' do
    let(:hsh_in) do
      {
        street: '1234 East Fair Boulevard',
        city: 'Austin',
        state: 'Texas',
        zip: '78734'
      }
    end

    let(:full_adr_out) { '1234 East Fair Boulevard, Austin, Texas, 78734' }

    it 'make_full_address_original' do
      expect(adr_obj.make_full_address_original(hsh_in)).to eql(full_adr_out)
    end
  end

  describe '#make_full_addr_f' do
    let(:hsh_in) do
      {
        street_f: '1234 E Fair Blvd',
        city_f: 'Austin',
        state_f: 'TX',
        zip_f: '78734',
        full_addr: '1234 East Fair Boulevard, Austin, Texas, 78734'
      }
    end
    let(:full_adr_out) { '1234 E Fair Blvd, Austin, TX, 78734' }

    it 'make_full_addr_f' do
      expect(adr_obj.make_full_addr_f(hsh_in)).to eql(full_adr_out)
    end
  end

  describe '#format_street' do
    let(:street_in) { '1234 East Fair Boulevard' }
    let(:street_out) { '1234 E Fair Blvd' }

    it 'format_street' do
      expect(adr_obj.format_street(street_in)).to eql(street_out)
    end
  end

  describe '#format_city' do
    let(:city_in) { 'austin' }
    let(:city_out) { 'Austin' }

    it 'format_city' do
      expect(adr_obj.format_city(city_in)).to eql(city_out)
    end
  end

  describe '#format_state' do
    let(:state_in) { 'Texas' }
    let(:state_out) { 'TX' }

    it 'format_state' do
      expect(adr_obj.format_state(state_in)).to eql(state_out)
    end
  end

  describe '#format_zip' do
    let(:zip_in) { '978734' }
    let(:zip_out) { nil }

    it 'format_zip' do
      expect(adr_obj.format_zip(zip_in)).to eql(zip_out)
    end
  end

  describe '#letter_case_check' do
    let(:str_in) { '1234 EAST FAIR BOULEVARD' }
    let(:str_out) { '1234 East Fair Boulevard' }

    it 'letter_case_check' do
      expect(adr_obj.letter_case_check(str_in)).to eql(str_out)
    end
  end
end
