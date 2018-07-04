# frozen_string_literal: false

# rspec spec/crm_formatter
require 'crm_formatter'
require 'spec_helper'

RSpec.describe CrmFormatter do
  let(:crmf_obj) { CrmFormatter }

  describe '#format_proper' do
    let(:input) { 'the gmc and bmw-world of AUSTIN tx' }
    let(:output) do
      {
        proper_status: 'formatted',
        proper: 'the gmc and bmw-world of AUSTIN tx',
        proper_f: 'The GMC and BMW-World of Austin TX'
      }
    end

    it 'format_proper' do
      expect(crmf_obj.format_proper(input)).to eql(output)
    end
  end

  describe '#format_propers' do
    let(:array_of_propers) do
      array_of_propers = [
        'the gmc and bmw-world of AUSTIN tx',
        '123 Car-world Kia OF CHICAGO IL',
        'Main Street Ford in DALLAS tX',
        'broad st fiat of houston',
        'hot-deal auto insurance',
        'BUDGET - AUTOMOTORES ZONA & FRANCA, INC',
        'DOWNTOWN CAR REPAIR, INC',
        'Young Gmc Trucks',
        'TEXAS TRAVEL, CO',
        'youmans Chevrolet',
        'quick auto approval, inc',
        'yazell chevy',
        'quick cAr LUBE',
        'yAtEs AuTo maLL',
        'YADKIN VALLEY COLLISION CO',
        'XIT FORD INC'
      ]
    end

    let(:formatted_proper_hashes) do
      [
        {
          proper_status: 'formatted',
          proper: 'the gmc and bmw-world of AUSTIN tx',
          proper_f: 'The GMC and BMW-World of Austin TX'
        },
        {
          proper_status: 'formatted',
          proper: '123 Car-world Kia OF CHICAGO IL',
          proper_f: '123 Car-World Kia of Chicago IL'
        },
        {
          proper_status: 'formatted',
          proper: 'Main Street Ford in DALLAS tX',
          proper_f: 'Main Street Ford in Dallas TX'
        },
        {
          proper_status: 'formatted',
          proper: 'broad st fiat of houston',
          proper_f: 'Broad St Fiat of Houston'
        },
        {
          proper_status: 'formatted',
          proper: 'hot-deal auto insurance',
          proper_f: 'Hot-Deal Auto Insurance'
        },
        {
          proper_status: 'formatted',
          proper: 'BUDGET - AUTOMOTORES ZONA & FRANCA, INC',
          proper_f: 'Budget - Automotores Zona & Franca, Inc'
        },
        {
          proper_status: 'formatted',
          proper: 'DOWNTOWN CAR REPAIR, INC',
          proper_f: 'Downtown Car Repair, Inc'
        },
        {
          proper_status: 'formatted',
          proper: 'Young Gmc Trucks',
          proper_f: 'Young GMC Trucks'
        },
        {
          proper_status: 'formatted',
          proper: 'TEXAS TRAVEL, CO',
          proper_f: 'Texas Travel, Co'
        },
        {
          proper_status: 'formatted',
          proper: 'youmans Chevrolet',
          proper_f: 'Youmans Chevrolet'
        },
        {
          proper_status: 'formatted',
          proper: 'quick auto approval, inc',
          proper_f: 'Quick Auto Approval, Inc'
        },
        {
          proper_status: 'formatted',
          proper: 'yazell chevy',
          proper_f: 'Yazell Chevy'
        },
        {
          proper_status: 'formatted',
          proper: 'quick cAr LUBE',
          proper_f: 'Quick Car Lube'
        },
        {
          proper_status: 'formatted',
          proper: 'yAtEs AuTo maLL',
          proper_f: 'Yates Auto Mall'
        },
        {
          proper_status: 'formatted',
          proper: 'YADKIN VALLEY COLLISION CO',
          proper_f: 'Yadkin Valley Collision Co'
        },
        {
          proper_status: 'formatted',
          proper: 'XIT FORD INC',
          proper_f: 'Xit Ford Inc'
        }
      ]
    end

    it 'format_propers' do
      expect(crmf_obj.format_propers(array_of_propers)).to eql(formatted_proper_hashes)
    end
  end

  describe '#format_with_report' do
    let(:file_path) do
      { file_path: './lib/crm_formatter/csv/seed.csv' }
    end

    let(:data) do
      { data:
        [
          { row_id: '1',
            url: 'abcacura.com/twitter',
            act_name: "Stanley Chevrolet Kaufman\x99_\xCC",
            street: '825 East Fair Street',
            city: 'Kaufman',
            state: 'Texas',
            zip: '75142',
            phone: "555-457-4391\r\n" }
        ] }
    end

    let(:formatted_csv_result) do
      { stats:
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
          error_data: []
        },
        file_path: './lib/crm_formatter/csv/seed.csv' }
    end

    let(:formatted_data_hash_result) do
      { stats:
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
        file_path: nil }
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

  describe '#format_addresses' do
    let(:array_of_addresses) do
      [
        {
          street: '1234 East Fair Boulevard',
          city: 'Austin',
          state: 'Texas',
          zip: '78734'
        },
        {
          street: '5678 North Lake Shore Drive',
          city: '555-123-4567',
          state: 'Illinois',
          zip: '610'
        },
        {
          street: '9123 West Flagler Street',
          city: '1233144',
          state: 'NotAState',
          zip: 'Miami'
        }
      ]
    end
    let(:formatted_address_hashes) do
      [
        {
          address_status: 'formatted',
          full_addr: '1234 East Fair Boulevard, Austin, Texas, 78734',
          full_addr_f: '1234 E Fair Blvd, Austin, TX, 78734',
          street_f: '1234 E Fair Blvd',
          city_f: 'Austin',
          state_f: 'TX',
          zip_f: '78734'
        },
        {
          address_status: 'formatted',
          full_addr: '5678 North Lake Shore Drive, 555-123-4567, Illinois, 610',
          full_addr_f: '5678 N Lake Shore Dr, IL',
          street_f: '5678 N Lake Shore Dr',
          city_f: nil,
          state_f: 'IL',
          zip_f: nil
        },
        {
          address_status: 'formatted',
          full_addr: '9123 West Flagler Street, 1233144, NotAState, Miami',
          full_addr_f: '9123 W Flagler St',
          street_f: '9123 W Flagler St',
          city_f: nil,
          state_f: nil,
          zip_f: nil
        }
      ]
    end

    it 'format_addresses' do
      expect(crmf_obj.format_addresses(array_of_addresses)).to eql(formatted_address_hashes)
    end
  end

  describe '#format_phones' do
    let(:array_of_phones) do
      %w[555-457-4391 555-888-4391 555-457-4334 555-555 555.555.1234 not_a_number]
    end
    let(:formatted_phone_hashes) do
      [
        {
          phone_status: 'formatted',
          phone: '555-457-4391',
          phone_f: '(555) 457-4391'
        },
        {
          phone_status: 'formatted',
          phone: '555-888-4391',
          phone_f: '(555) 888-4391'
        },
        {
          phone_status: 'formatted',
          phone: '555-457-4334',
          phone_f: '(555) 457-4334'
        },
        {
          phone_status: 'invalid',
          phone: '555-555',
          phone_f: nil
        },
        {
          phone_status: 'formatted',
          phone: '555.555.1234',
          phone_f: '(555) 555-1234'
        },
        {
          phone_status: 'invalid',
          phone: 'not_a_number',
          phone_f: nil
        }
      ]
    end

    it 'format_phones' do
      expect(crmf_obj.format_phones(array_of_phones)).to eql(formatted_phone_hashes)
    end
  end

  describe '#format_urls' do
    let(:array_of_urls) do
      %w[www.sample01.net.com sample02.com http://www.sample3.net www.sample04.net/contact_us http://sample05.net www.sample06.sofake www.sample07.com.sofake example08.not.real www.sample09.net/staff/management www.www.sample10.com]
    end

    let(:formatted_url_hashes) do
      [
        {
          web_status: 'invalid',
          url: 'www.sample01.net.com',
          url_f: nil,
          url_path: nil,
          web_neg: 'error: ext.valid > 1 [com, net]'
        },
        {
          web_status: 'formatted',
          url: 'sample02.com',
          url_f: 'http://www.sample02.com',
          url_path: nil,
          web_neg: nil
        },
        {
          web_status: 'unchanged',
          url: 'http://www.sample3.net',
          url_f: 'http://www.sample3.net',
          url_path: nil,
          web_neg: nil
        },
        {
          web_status: 'formatted',
          url: 'www.sample04.net/contact_us',
          url_f: 'http://www.sample04.net',
          url_path: '/contact_us',
          web_neg: nil
        },
        {
          web_status: 'formatted',
          url: 'http://sample05.net',
          url_f: 'http://www.sample05.net',
          url_path: nil,
          web_neg: nil
        },
        {
          web_status: 'invalid',
          url: 'www.sample06.sofake',
          url_f: nil,
          url_path: nil,
          web_neg: 'error: ext.invalid [sofake]'
        },
        {
          web_status: 'formatted',
          url: 'www.sample07.com.sofake',
          url_f: 'http://www.sample07.com',
          url_path: nil,
          web_neg: nil
        },
        {
          web_status: 'invalid',
          url: 'example08.not.real',
          url_f: nil,
          url_path: nil,
          web_neg: 'error: ext.invalid [not, real]'
        },
        {
          web_status: 'formatted',
          url: 'www.sample09.net/staff/management',
          url_f: 'http://www.sample09.net',
          url_path: '/staff/management',
          web_neg: nil
        },
        {
          web_status: 'formatted',
          url: 'www.www.sample10.com',
          url_f: 'http://www.sample10.com',
          url_path: nil,
          web_neg: nil
        }
      ]
    end

    it 'format_urls' do
      expect(crmf_obj.format_urls(array_of_urls)).to eql(formatted_url_hashes)
    end
  end
end
