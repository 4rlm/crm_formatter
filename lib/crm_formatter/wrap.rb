# frozen_string_literal: false
require 'csv'

module CrmFormatter
  class Wrap
    def initialize
      @crm_data = {}
      @tools = CrmFormatter::Tools.new
      @global_hash = @tools.grab_global_hash
    end

    ## Starting point of class. Can call run_wrap method to run.
    def run_wrap(args={})
      # sanitized_data = Utf8Sanitizer.sanitize
      orig_hashes = [{ :row_id=>"1", :url=>"stanleykaufman.com", :act_name=>"Stanley Chevrolet Kaufman\x99_\xCC", :street=>"825 E Fair St", :city=>"Kaufman", :state=>"TX", :zip=>"75142", :phone=>"(888) 457-4391\r\n" }]

      # sanitized_data = Utf8Sanitizer.sanitize(data: orig_hashes)
      sanitized_data = Utf8Sanitizer.sanitize(file_path: './lib/crm_formatter/csv/seeds_dirty_1.csv')

      sanitized_hashes = sanitized_data[:data][:valid_data]
      binding.pry

      return "Stop Here for Now!"
      ### Integrate with Below after above working well. ###

      import_crm_data(args={})
      format_crm_data
      puts @crm_data.inspect
      @crm_data
      ## Exit point from this class. Should return @crm_data.
    end


    def import_crm_data(args={})
      @crm_data = { stats: nil, data: nil, file_path: nil, criteria: nil }
      @crm_data.merge!(args)
      keys = args.compact.keys

      unless (keys & [:data, :file_path]).any?
        @crm_data[:file_path] = Seed.new.grab_seed_file_path
        # @crm_data[:data] = Seed.new.grab_seed_hashes
        @crm_data[:pollute_seeds] = true
        unless keys.include?(:criteria)
          @crm_data[:criteria] = Seed.new.grab_seed_web_criteria
        end
      end

      utf_result = CrmFormatter::UTF.new.validate_data(@crm_data)
      @crm_data.merge!(utf_result)
    end


    def format_crm_data
      return unless @crm_data[:data][:valid_data].any?
      web = CrmFormatter::Web.new(@crm_data[:criteria])
      phone = CrmFormatter::Phone.new
      address = CrmFormatter::Address.new

      @crm_data[:data][:valid_data].map! do |valid_hash|
        local_hash = @global_hash
        crmf_url_hsh = web.format_url(valid_hash[:url])
        crmf_phone_hsh = phone.validate_phone(valid_hash[:phone])
        adr_hsh = valid_hash.slice(:street, :city, :state, :zip)
        crmf_adr_hsh = address.format_full_address(adr_hsh)

        local_hash = local_hash.merge(valid_hash)
        local_hash = local_hash.merge(crmf_url_hsh)
        local_hash = local_hash.merge(crmf_phone_hsh)
        local_hash = local_hash.merge(crmf_adr_hsh)
        puts "NEED to work on 'status' for each."
        local_hash
      end
    end


    def format_phones(args={})
      return unless @crm_data[:data][:valid_data].any?
      phone = CrmFormatter::Phone.new

      @crm_data[:data][:valid_data].map! do |valid_hash|
        formatted_hash = phone.validate_phone(valid_hash[:phone])
        local = @global_hash
        local = local.merge(valid_hash)
        local = local.merge(formatted_hash)
        local
      end
    end










    ###############################################
    def self.export(hash)
      # CSV.generate do |csv|
      #   csv << @model.attribute_names
      #   @model.all.each { |r| csv << r.attributes.values }
      # end

      ### LONGER EXAMPLE ###
      # CSV.generate(options = {}) do |csv|
      # csv.add_row(cont_cols + web_cols + brand_cols)
      # conts.each do |cont|
      #   values = cont.attribute_vals(cont_cols)
      #   values += cont.web.attribute_vals(web_cols)
      #   values << cont.web.brands_to_string
      #   csv.add_row(values)
      # end
    end

  end
end
