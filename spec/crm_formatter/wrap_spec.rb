# frozen_string_literal: true

# rspec spec/crm_formatter/wrap_spec.rb
require 'spec_helper'

describe 'Wrap' do
  let(:wrap_obj) { CrmFormatter::Wrap.new }

  let(:global_hash) do
    {
      row_id: nil,
      act_name: nil,
      street: nil,
      city: nil,
      state: nil,
      zip: nil,
      full_addr: nil,
      phone: nil,
      url: nil,
      street_f: nil,
      city_f: nil,
      state_f: nil,
      zip_f: nil,
      full_addr_f: nil,
      phone_f: nil,
      url_f: nil,
      url_path: nil,
      web_neg: nil,
      address_status: nil,
      phone_status: nil,
      web_status: nil,
      utf_status: nil
    }
  end

  before { wrap_obj.crm_data = {} }
  before { wrap_obj.global_hash = global_hash }

  describe '#grab_global_hash' do
    it 'grab_global_hash' do
      expect(wrap_obj.grab_global_hash).to eql(global_hash)
    end
  end

  describe '#run' do
    context 'run w/ file_path' do
      let(:file_path) { { file_path: './lib/crm_formatter/csv/seed.csv' } }
      let(:crm_data_out) do
        {
          stats:
            {
              total_rows: 2,
              header_row: 1,
              valid_rows: 1,
              error_rows: 0,
              defective_rows: 0,
              perfect_rows: 0,
              encoded_rows: 1,
              wchar_rows: 0
            },
          data:
            { valid_data:
              [
                {
                  row_id: 1,
                  act_name: 'Courtesy Ford',
                  street: '1410 West Pine Street Hattiesburg',
                  city: 'Wexford',
                  state: 'MS',
                  zip: '39401',
                  full_addr: '1410 West Pine Street Hattiesburg, Wexford, MS, 39401',
                  phone: '512-555-1212',
                  url: 'http://www.courtesyfordsales.com',
                  street_f: '1410 W Pine St Hattiesburg',
                  city_f: 'Wexford',
                  state_f: 'MS',
                  zip_f: '39401',
                  full_addr_f: '1410 W Pine St Hattiesburg, Wexford, MS, 39401',
                  phone_f: '(512) 555-1212',
                  url_f: 'http://www.courtesyfordsales.com',
                  url_path: nil,
                  web_neg: nil,
                  address_status: 'formatted',
                  phone_status: 'formatted',
                  web_status: 'unchanged',
                  utf_status: 'encoded'
                }
              ],
              encoded_data:
        [
          { row_id: 1,
            text: "http://www.courtesyfordsales.com,Courtesy Ford,__\xD5\xCB\xEB\x8F\xEB__\xD5\xCB\xEB\x8F\xEB____1410 West Pine Street Hattiesburg,Wexford,MS,39401,512-555-1212" }
        ],
              defective_data: [],
              error_data: [] },
          file_path: './lib/crm_formatter/csv/seed.csv'
        }
      end

      it 'run w/ file_path' do
        expect(wrap_obj.run(file_path)).to eql(crm_data_out)
      end
    end

    context 'run w/ data hash' do
      let(:data_in) do
        { data:
          [
            {
              row_id: '1',
              url: 'abcacura.com/twitter',
              act_name: "Stanley Chevrolet Kaufman\x99_\xCC",
              street: '825 East Fair Street',
              city: 'Kaufman',
              state: 'Texas',
              zip: '75142',
              phone: "555-457-4391\r\n"
            }
          ] }
      end

      let(:crm_data_out) do
        {
          stats:
          {
            total_rows: '1',
            header_row: 1,
            valid_rows: 1,
            error_rows: 0,
            defective_rows: 0,
            perfect_rows: 0,
            encoded_rows: 1,
            wchar_rows: 1
          },
          data:
            {
              valid_data:
                [
                  {
                    row_id: '1',
                    act_name: 'Stanley Chevrolet Kaufman',
                    street: '825 East Fair Street',
                    city: 'Kaufman',
                    state: 'Texas',
                    zip: '75142',
                    full_addr: '825 East Fair Street, Kaufman, Texas, 75142',
                    phone: '555-457-4391',
                    url: 'abcacura.com/twitter',
                    street_f: '825 E Fair St',
                    city_f: 'Kaufman',
                    state_f: 'TX',
                    zip_f: '75142',
                    full_addr_f: '825 E Fair St, Kaufman, TX, 75142',
                    phone_f: '(555) 457-4391',
                    url_f: 'http://www.abcacura.com',
                    url_path: '/twitter',
                    web_neg: nil,
                    address_status: 'formatted',
                    phone_status: 'formatted',
                    web_status: 'formatted',
                    utf_status: 'encoded, wchar'
                  }
                ],
              encoded_data:
              [
                {
                  row_id: '1',
                  text: "1,abcacura.com/twitter,Stanley Chevrolet Kaufman\x99_\xCC,825 East Fair Street,Kaufman,Texas,75142,555-457-4391\r\n"
                }
              ],
              defective_data: [],
              error_data: []
            },
          file_path: nil
        }
      end

      it 'run w/ data hash' do
        expect(wrap_obj.run(data_in)).to eql(crm_data_out)
      end
    end
  end

  describe '#import_crm_data' do
    context 'import_crm_data w/ file_path' do
      let(:file_path) { { file_path: './lib/crm_formatter/csv/seed.csv' } }
      let(:crm_data_out) do
        {
          stats:
            { total_rows: 2,
              header_row: 1,
              valid_rows: 1,
              error_rows: 0,
              defective_rows: 0,
              perfect_rows: 0,
              encoded_rows: 1,
              wchar_rows: 0 },
          data:
            { valid_data:
              [
                {
                  row_id: 1,
                  utf_status: 'encoded',
                  url: 'http://www.courtesyfordsales.com',
                  act_name: 'Courtesy Ford',
                  street: '1410 West Pine Street Hattiesburg',
                  city: 'Wexford',
                  state: 'MS',
                  zip: '39401',
                  phone: '512-555-1212'
                }
              ],
              encoded_data:
          [
            { row_id: 1,
              text: "http://www.courtesyfordsales.com,Courtesy Ford,__\xD5\xCB\xEB\x8F\xEB__\xD5\xCB\xEB\x8F\xEB____1410 West Pine Street Hattiesburg,Wexford,MS,39401,512-555-1212" }
          ],
              defective_data: [],
              error_data: [] },
          file_path: './lib/crm_formatter/csv/seed.csv'
        }
      end

      it 'import_crm_data w/ file_path' do
        expect(wrap_obj.import_crm_data(file_path)).to eql(crm_data_out)
      end
    end

    context 'import_crm_data w/ data hash' do
      let(:data_in) do
        { data:
          [
            {
              row_id: '1',
              url: 'abcacura.com/twitter',
              act_name: "Stanley Chevrolet Kaufman\x99_\xCC",
              street: '825 East Fair Street',
              city: 'Kaufman',
              state: 'Texas',
              zip: '75142',
              phone: "555-457-4391\r\n"
            }
          ] }
      end

      let(:crm_data_out) do
        {
          stats:
          {
            total_rows: '1',
            header_row: 1,
            valid_rows: 1,
            error_rows: 0,
            defective_rows: 0,
            perfect_rows: 0,
            encoded_rows: 1,
            wchar_rows: 1
          },
          data:
            { valid_data:
              [
                { row_id: '1',
                  utf_status: 'encoded, wchar',
                  url: 'abcacura.com/twitter',
                  act_name: 'Stanley Chevrolet Kaufman',
                  street: '825 East Fair Street',
                  city: 'Kaufman',
                  state: 'Texas',
                  zip: '75142',
                  phone: '555-457-4391' }
              ],
              encoded_data:
          [
            {
              row_id: '1',
              text: "1,abcacura.com/twitter,Stanley Chevrolet Kaufman\x99_\xCC,825 East Fair Street,Kaufman,Texas,75142,555-457-4391\r\n"
            }
          ],
              defective_data: [],
              error_data: [] },
          file_path: nil
        }
      end

      it 'import_crm_data w/ data hash' do
        expect(wrap_obj.import_crm_data(data_in)).to eql(crm_data_out)
      end
    end
  end

  describe '#format_data' do
    let(:crm_data) do
      {
        stats:
        {
          total_rows: 2,
          header_row: 1,
          valid_rows: 1,
          error_rows: 0,
          defective_rows: 0,
          perfect_rows: 0,
          encoded_rows: 1,
          wchar_rows: 0
        },
        data:
        {
          valid_data:
          [
            {
              row_id: 1,
              utf_status: 'encoded',
              url: 'http://www.courtesyfordsales.com',
              act_name: 'Courtesy Ford',
              street: '1410 West Pine Street Hattiesburg',
              city: 'Wexford',
              state: 'MS',
              zip: '39401',
              phone: '512-555-1212'
            }
          ],
          encoded_data:
          [
            { row_id: 1,
              text: "http://www.courtesyfordsales.com,Courtesy Ford,__\xD5\xCB\xEB\x8F\xEB__\xD5\xCB\xEB\x8F\xEB____1410 West Pine Street Hattiesburg,Wexford,MS,39401,512-555-1212" }
          ],
          defective_data: [],
          error_data: []
        },
        file_path: './lib/crm_formatter/csv/seed.csv'
      }
    end

    before { wrap_obj.crm_data = crm_data }

    let(:local_hash_out) do
      [
        {
          row_id: 1,
          act_name: 'Courtesy Ford',
          street: '1410 West Pine Street Hattiesburg',
          city: 'Wexford',
          state: 'MS',
          zip: '39401',
          full_addr: '1410 West Pine Street Hattiesburg, Wexford, MS, 39401',
          phone: '512-555-1212',
          url: 'http://www.courtesyfordsales.com',
          street_f: '1410 W Pine St Hattiesburg',
          city_f: 'Wexford',
          state_f: 'MS',
          zip_f: '39401',
          full_addr_f: '1410 W Pine St Hattiesburg, Wexford, MS, 39401',
          phone_f: '(512) 555-1212',
          url_f: 'http://www.courtesyfordsales.com',
          url_path: nil,
          web_neg: nil,
          address_status: 'formatted',
          phone_status: 'formatted',
          web_status: 'unchanged',
          utf_status: 'encoded'
        }
      ]
    end

    it 'format_data' do
      expect(wrap_obj.format_data).to eql(local_hash_out)
    end
  end
end
