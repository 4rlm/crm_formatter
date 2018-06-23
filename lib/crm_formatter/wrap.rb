# frozen_string_literal: false
require 'csv'

module CrmFormatter
  class Wrap
    def initialize
      @crm_data = {}
      @global_hash = CrmFormatter::Tools.new.grab_global_hash
    end

    def run(args={})
      import_crm_data(args)
      format_data
      puts @crm_data.inspect
      @crm_data
    end


    def import_crm_data(args={})
      @crm_data = { stats: nil, data: nil, file_path: nil, criteria: nil }
      @crm_data.merge!(args)
      utf_result = Utf8Sanitizer.sanitize(@crm_data)
      @crm_data.merge!(utf_result)
    end


    def format_data
      return unless @crm_data[:data][:valid_data].any?
      address = CrmFormatter::Address.new
      phone = CrmFormatter::Phone.new
      web = CrmFormatter::Web.new(@crm_data[:criteria])

      @crm_data[:data][:valid_data].map! do |valid_hash|
        local_hash = @global_hash
        crmf_url_hsh = web.format_url(valid_hash[:url])
        crmf_phone_hsh = phone.validate_phone(valid_hash[:phone])

        adr_hsh = valid_hash.slice(:street, :city, :state, :zip)
        crmf_adr_hsh = address.format_full_address(adr_hsh)
        binding.pry
        local_hash = local_hash.merge(valid_hash)
        local_hash = local_hash.merge(crmf_url_hsh)
        local_hash = local_hash.merge(crmf_phone_hsh)
        local_hash = local_hash.merge(crmf_adr_hsh)
        local_hash
      end
    end

  end
end
