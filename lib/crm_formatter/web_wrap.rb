# frozen_string_literal: true
require 'csv'

module CrmFormatter
  class WebWrap
    def initialize
      @crm_data = []
      @tools = CrmFormatter::Tools.new
      @global_hash = @tools.grab_global_hash
    end

    ## Starting point of class. Can call wrap method to run.
    def wrap(args={})
      import_data(args={})
      format_urls
      format_phones
      binding.pry
      puts @crm_data.inspect
      @crm_data
      ## Exit point from this class. Should return @crm_data.
    end


    def import_data(args={})
      file_path = args.fetch(:file_path, nil)
      data = args.fetch(:data, nil)
      args = { file_path: file_path, data: data }

      unless args.values.any?
        # args = { file_path: Seed.new.grab_seed_csv, pollute_seeds: true }
        args = { data: Seed.new.grab_seed_hashes, pollute_seeds: true }
      end

      @crm_data = CrmFormatter::UTF.new.validate_data(args)
    end


    def format_urls(args={})
      # import_data(args = {}) ## data sent to @crm_data
      return unless @crm_data[:data][:valid_data].any?
      args = Seed.new.grab_seed_web_criteria if args.blank?
      web = CrmFormatter::Web.new(args)

      @crm_data[:data][:valid_data].map! do |valid_hash|
        formatted_hash = web.format_url(valid_hash[:url])
        local = @global_hash
        local = local.merge(valid_hash)
        local = local.merge(formatted_hash)
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
        binding.pry
        local
      end
      binding.pry
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
