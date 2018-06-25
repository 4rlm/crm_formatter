# frozen_string_literal: false

# rspec spec/crm_formatter
require 'crm_formatter'
require 'spec_helper'

RSpec.describe CrmFormatter do
  it 'has a version number' do
    expect(CrmFormatter::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(true).to eq(true)
  end

  #### Examples Above ####
  let(:crmf_obj) { CrmFormatter }

  describe '#format_with_report' do
    let(:file_path) do
      { file_path: './lib/crm_formatter/csv/seeds_dirty_1.csv' }
    end

    let(:data) do
      { data: [
        { row_id: '1',
          url: 'stanleykaufman.com',
          act_name: "Stanley Chevrolet Kaufman\x99_\xCC",
          street: '825 E Fair St',
          city: 'Kaufman',
          state: 'TX', zip: '75142',
          phone: "555-457-4391\r\n" }
      ] }
    end

    let(:formatted_csv_result) do
      { stats: {
        total_rows: 2,
        header_row: 1,
        valid_rows: 1,
        error_rows: 0,
        defective_rows: 0,
        perfect_rows: 0,
        encoded_rows: 1,
        wchar_rows: 0
      },
        data:        {
          valid_data:          [
            { row_id: 1,
              act_name: 'Courtesy Ford',
              street: '1410 West Pine Street Hattiesburg',
              city: 'Wexford',
              state: 'MS',
              zip: '39401',
              full_addr: '1410 West Pine Street Hattiesburg, Wexford, MS, 39401',
              phone: '512-555-1212',
              url: 'courtesyfordsales.com',
              url_path: 'courtesyfordsales.com',
              street_f: '1410 W Pine St Hattiesburg',
              city_f: 'Wexford',
              state_f: 'MS',
              zip_f: '39401',
              full_addr_f: '1410 W Pine St Hattiesburg, Wexford, MS, 39401',
              phone_f: '(512) 555-1212',
              url_f: 'http://www.courtesyfordsales.com',
              web_neg: nil,
              web_pos: nil,
              address_status: 'formatted',
              phone_status: 'formatted',
              web_status: 'formatted',
              utf_status: 'encoded' }
          ],
          encoded_data:           [
            { row_id: 1,
              text: "courtesyfordsales.com,Courtesy Ford,__\x95\xC0_\x95\xC0_\x95\xC0_\x95\xC0_\x95\xC0___\x95\xC0_\x95\xC0_\x95\xC0_\x95\xC0_\x95\xC0_____1410 West Pine Street Hattiesburg,Wexford,MS,39401,512-555-1212" }
          ],
          defective_data: [],
          error_data: []
        },
        file_path: './lib/crm_formatter/csv/seeds_dirty_1.csv',
      }
    end

    let(:formatted_data_hash_result) do
      { stats: {
        total_rows: '1',
        header_row: 1,
        valid_rows: 1,
        error_rows: 0,
        defective_rows: 0,
        perfect_rows: 0,
        encoded_rows: 1,
        wchar_rows: 1
      },
        data:   {
          valid_data:     [
            { row_id: '1',
              act_name: 'Stanley Chevrolet Kaufman',
              street: '825 E Fair St',
              city: 'Kaufman',
              state: 'TX',
              zip: '75142',
              full_addr: '825 E Fair St, Kaufman, TX, 75142',
              phone: '555-457-4391',
              url: 'stanleykaufman.com',
              url_path: 'stanleykaufman.com',
              street_f: '825 E Fair St',
              city_f: 'Kaufman',
              state_f: 'TX',
              zip_f: '75142',
              full_addr_f: '825 E Fair St, Kaufman, TX, 75142',
              phone_f: '(555) 457-4391',
              url_f: 'http://www.stanleykaufman.com',
              web_neg: nil,
              web_pos: nil,
              address_status: 'unchanged',
              phone_status: 'formatted',
              web_status: 'formatted',
              utf_status: 'encoded, wchar' }
          ],
          encoded_data: [
            { row_id: '1',
              text: "1,stanleykaufman.com,Stanley Chevrolet Kaufman\x99_\xCC,825 E Fair St,Kaufman,TX,75142,555-457-4391\r\n" }
          ],
          defective_data: [],
          error_data: []
        },
        file_path: nil,
      }
    end

    context 'formats csv with report' do
      it 'formats csv with report' do
        expect(crmf_obj.format_with_report(file_path)).to eql(formatted_csv_result)
      end
    end

    context 'formats data hashes with report' do
      it 'formats data hashes with report' do
        expect(crmf_obj.format_with_report(data)).to eql(formatted_data_hash_result)
      end
    end
  end
end
