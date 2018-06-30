# frozen_string_literal: false

require 'crm_formatter/address'
require 'crm_formatter/extensions'
require 'crm_formatter/phone'
require 'crm_formatter/proper'
require 'crm_formatter/tools'
require 'crm_formatter/web'
require 'crm_formatter/wrap'

require 'utf8_sanitizer'

# require 'crm_formatter/tools'
# require 'crm_formatter/seed_criteria'
# require 'pry'

module CrmFormatter

  ## Takes array of proper strings, returns array of proper hashes.
  def self.format_propers(array_of_propers)
    proper_obj = CrmFormatter::Proper.new

    formatted_proper_hashes = array_of_propers.map do |string|
      crmf_proper_hsh = proper_obj.format_proper(string)
    end
    formatted_proper_hashes
  end


  ## Takes array of address hashes, returns array of address hashes.
  def self.format_addresses(array_of_addresses)
    address_obj = CrmFormatter::Address.new

    formatted_address_hashes = array_of_addresses.map do |address_hsh|
      crmf_adr_hsh = { address_status: nil, full_addr: nil, full_addr_f: nil }
      crmf_adr_hsh.merge!(address_obj.format_full_address(address_hsh))
      crmf_adr_hsh
    end
    formatted_address_hashes
  end

  ## Takes array of phone strings, returns array of phone hashes.
  def self.format_phones(array_of_phones)
    phone_obj = CrmFormatter::Phone.new

    formatted_phone_hashes = array_of_phones.map do |phone|
      crmf_phone_hsh = phone_obj.validate_phone(phone)
    end
    formatted_phone_hashes
  end

  ## Takes array of url strings, returns array of url hashes.
  def self.format_urls(array_of_urls)
    web_obj = CrmFormatter::Web.new

    formatted_url_hashes = array_of_urls.map do |url|
      crmf_url_hsh = { web_status: nil, url: url }
      crmf_url_hsh.merge!(web_obj.format_url(url))
      crmf_url_hsh
    end
    formatted_url_hashes
  end

  def self.format_with_report(args={})
    formatted_data = self::Wrap.new.run(args)
    formatted_data
  end

end
