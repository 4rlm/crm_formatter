# frozen_string_literal: false

# rspec spec/crm_formatter/web_spec.rb
require 'spec_helper'

describe 'Web' do
  # before { utf_obj.headers = headers }
  let(:web_obj) { CrmFormatter::Web.new }

  describe '#format_url' do
    let(:url_str_in) { 'www.sample01.net.com' }
    let(:url_hsh_out) do
      {
        web_status: 'invalid',
        url: 'www.sample01.net.com',
        url_f: nil,
        url_path: nil,
        web_neg: 'error: ext.valid > 1 [com, net]'
      }
    end

    it 'formats url' do
      expect(web_obj.format_url(url_str_in)).to eql(url_hsh_out)
    end
  end

  describe '#check_web_status' do
    let(:url_hsh_in) do
      {
        web_status: nil,
        url: 'www.sample01.net.com',
        url_f: nil,
        url_path: nil,
        web_neg: 'error: ext.valid > 1 [com, net]'
      }
    end

    let(:url_hsh_out) do
      {
        web_status: 'invalid',
        url: 'www.sample01.net.com',
        url_f: nil,
        url_path: nil,
        web_neg: 'error: ext.valid > 1 [com, net]'
      }
    end

    it 'compares orig and formatted url' do
      expect(web_obj.check_web_status(url_hsh_in)).to eql(url_hsh_out)
    end
  end

  describe '#prep_for_uri' do
    let(:url_str_in) { 'www.sample01.net.com' }

    let(:url_hsh_out) do
      {
        url_hash: { web_status: nil,
                    url: 'www.sample01.net.com',
                    url_f: nil,
                    url_path: nil, web_neg: [] },
        url: 'www.sample01.net.com'
      }
    end

    it 'prepares url for uri' do
      expect(web_obj.prep_for_uri(url_str_in)).to eql(url_hsh_out)
    end
  end

  describe '#normalize_url' do
    let(:url_str_in) { 'www.sample01.net.com' }
    let(:url_str_out) { 'http://www.sample01.net.com' }

    it 'normalizes url' do
      expect(web_obj.normalize_url(url_str_in)).to eql(url_str_out)
    end
  end

  describe '#validate_extension' do
    let(:url) { 'http://www.sample02.com' }

    let(:url_hash_in) do
      {
        web_status: nil,
        url: 'sample02.com',
        url_f: nil,
        url_path: nil,
        web_neg: []
      }
    end

    let(:url_hash_out) do
      {
        url_hash:           {
          web_status: nil,
          url: 'sample02.com',
          url_f: nil,
          url_path: nil,
          web_neg: []
        },
        url: 'http://www.sample02.com'
      }
    end

    it 'validates extension' do
      expect(web_obj.validate_extension(url_hash_in, url)).to eql(url_hash_out)
    end
  end

  describe '#extract_path' do
    let(:url_hsh_in) do
      {
        web_status: nil,
        url: 'sample01.com/staff',
        url_f: 'http://www.sample01.com/staff',
        url_path: nil,
        web_neg: nil
      }
    end

    let(:url_hsh_out) do
      {
        web_status: nil,
        url: 'sample01.com/staff',
        url_f: 'http://www.sample01.com',
        url_path: '/staff',
        web_neg: nil
      }
    end

    it 'extract_path' do
      expect(web_obj.extract_path(url_hsh_in)).to eql(url_hsh_out)
    end
  end

  describe '#remove_ww3' do
    let(:url_str_in) { 'www.www.sample01.net.com' }
    let(:url_str_out) { 'www.sample01.net.com' }

    it 'remove_ww3' do
      expect(web_obj.remove_ww3(url_str_in)).to eql(url_str_out)
    end
  end

  describe '#remove_slashes' do
    let(:url_str_in) { 'http://www.sample01.net/contact_us' }
    let(:url_str_out) { 'http://www.sample01.net/contact_us' }

    it 'remove_slashes' do
      expect(web_obj.remove_slashes(url_str_in)).to eql(url_str_out)
    end
  end
end
