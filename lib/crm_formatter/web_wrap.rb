# frozen_string_literal: true

require 'csv'

module CrmFormatter
  class WebWrap
    def initialize
      utf_args = { pollute_seeds: false, seed_hashes: true, seed_csv: false }
      @utf = CrmFormatter::UTF.new(utf_args)
      @crm_data = []
      # @crm_data[:data][:valid_data] ## path to 'valid data'
      # @crm_data[:stats] ## path to 'stats'
      @tools = CrmFormatter::Tools.new
      @global_hash = @tools.get_global_hash
    end

    ## Starting point of class. Can call wrap method to run.
    def wrap
      format_urls
      puts @crm_data[:data][:valid_data].inspect
      binding.pry
      @crm_data
      ## Exit point from this class. Should return @crm_data.
    end

    ## Wrap is currently set to call format_url method.
    def format_urls(args={})
      import_data(args = {}) ## data sent to @crm_data
      return unless @crm_data[:data][:valid_data].any?
      web = CrmFormatter::Web.new(get_web_args)

      @crm_data[:data][:valid_data].map! do |valid_hash|
        formatted_hash = web.format_url(valid_hash[:url])
        local = @global_hash
        local = local.merge(valid_hash)
        local = local.merge(formatted_hash)
      end
      ## Need to ensure formatted_data is saving/updating @crm_data. !!!
    end

    ## Accepted arg keys & values: either :file_path, or :hashes.
    def import_data(args={})
      args = { file_path: @utf.get_seed_file_path }
      # args = {data: @utf.get_seed_hashes}
      @crm_data = @utf.validate_data(args)
    end

    def get_web_args
      neg_urls = %w[approv avis budget collis eat enterprise facebook financ food google gourmet hertz hotel hyatt insur invest loan lube mobility motel motorola parts quick rent repair restaur rv ryder service softwar travel twitter webhost yellowpages yelp youtube]

      pos_urls = ['acura', 'alfa romeo', 'aston martin', 'audi', 'bmw', 'bentley', 'bugatti', 'buick', 'cdjr', 'cadillac', 'chevrolet', 'chrysler', 'dodge', 'ferrari', 'fiat', 'ford', 'gmc', 'group', 'group', 'honda', 'hummer', 'hyundai', 'infiniti', 'isuzu', 'jaguar', 'jeep', 'kia', 'lamborghini', 'lexus', 'lincoln', 'lotus', 'mini', 'maserati', 'mazda', 'mclaren', 'mercedes-benz', 'mitsubishi', 'nissan', 'porsche', 'ram', 'rolls-royce', 'saab', 'scion', 'smart', 'subaru', 'suzuki', 'toyota', 'volkswagen', 'volvo']

      # neg_links = %w(: .biz .co .edu .gov .jpg .net // afri anounc book business buy bye call cash cheap click collis cont distrib download drop event face feature feed financ find fleet form gas generat graphic hello home hospi hour hours http info insta inventory item join login mail mailto mobile movie museu music news none offer part phone policy priva pump rate regist review schedul school service shop site test ticket tire tv twitter watch www yelp youth)

      # neg_hrefs = %w(? .com .jpg @ * afri after anounc apply approved blog book business buy call care career cash charit cheap check click collis commerc cont contrib deal distrib download employ event face feature feed financ find fleet form gas generat golf here holiday hospi hour info insta inventory join later light login mail mobile movie museu music news none now oil part pay phone policy priva pump quick quote rate regist review saving schedul service shop sign site speci ticket tire today transla travel truck tv twitter watch youth)

      neg_exts = %w[au ca edu es gov in ru uk us]
      # oa_args = {neg_urls: neg_urls, pos_urls: pos_urls, neg_exts: neg_exts}
      oa_args = { neg_exts: neg_exts, pos_urls: pos_urls, neg_urls: neg_urls }
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
