# frozen_string_literal: false
require 'csv'

module CrmFormatter
  class Wrap
    def initialize
      @crm_data = {}
      # @global_hash = CrmFormatter::Tools.new.grab_global_hash
      @global_hash = grab_global_hash
    end

    def grab_global_hash
      keys = %i[row_id act_name street city state zip full_addr phone url street_f city_f state_f zip_f full_addr_f phone_f url_f url_path web_neg address_status phone_status web_status utf_status]
      @global_hash = Hash[keys.map { |a| [a, nil] }]
    end

    def run(args={})
      import_crm_data(args)
      format_data
      puts @crm_data.inspect
      @crm_data
    end


    def import_crm_data(args={})
      # @crm_data = { stats: nil, data: nil, file_path: nil, criteria: nil }
      @crm_data = { stats: nil, data: nil, file_path: nil }
      @crm_data.merge!(args)
      utf_result = Utf8Sanitizer.sanitize(@crm_data)
      @crm_data.merge!(utf_result)
    end


    def format_data
      return unless @crm_data[:data][:valid_data].any?
      adr_obj = CrmFormatter::Address.new
      phone_obj = CrmFormatter::Phone.new
      web_obj = CrmFormatter::Web.new

      @crm_data[:data][:valid_data].map! do |valid_hash|
        local_hash = @global_hash
        crmf_url_hsh = web_obj.format_url(valid_hash[:url])
        crmf_phone_hsh = phone_obj.validate_phone(valid_hash[:phone])

        adr_hsh = valid_hash.slice(:street, :city, :state, :zip)
        crmf_adr_hsh = adr_obj.format_full_address(adr_hsh)
        local_hash = local_hash.merge(valid_hash)
        local_hash = local_hash.merge(crmf_url_hsh)
        local_hash = local_hash.merge(crmf_phone_hsh)
        local_hash = local_hash.merge(crmf_adr_hsh)
        local_hash
      end
    end

  end
end
