require 'csv'

module CrmFormatter
  class WebWrap

    def initialize
      @utf = CrmFormatter::UTF.new
      @crm_data = []
    end


    def wrap
      formatted_urls = format_urls
      binding.pry if formatted_urls.any?
      formatted_urls
    end


    def format_urls(args={})
      import_data(args={}) ## data sent to @crm_data
      binding.pry

      ### @crm_data is clean.  It can now run through formatter.
      if @crm_data.any?
        binding.pry
        web = CrmFormatter::Web.new(get_args)
        binding.pry

        @crm_data.map do |web|
          url = web[:url]
          binding.pry
          url_hsh = web.format_url(url)
          binding.pry
        end
      end
    end


    ## Accepted arg keys & values: either :file_path, :arrays, or :hashes.
    def import_data(args={})
      ## Need to test if permitted args works.
      args = {hashes: get_seed_hashes}

      if args.any?
        permitted_arg = get_path_hash_url_args(args)
      else
        # permitted_arg = {file_path: "./lib/crm_formatter/csv/seeds_clean.csv"}
        # permitted_arg = {file_path: "./lib/crm_formatter/csv/seeds_dirty.csv"}
        # permitted_arg = {file_path: "./lib/crm_formatter/csv/seeds_mega.csv"}
        permitted_arg = {file_path: "./lib/crm_formatter/csv/seeds_mini.csv"}
        permitted_arg = {file_path: "./lib/crm_formatter/csv/seeds_mini_10.csv"}
      end

      @crm_data = @utf.validate_data(permitted_arg) if permitted_arg.any?
      binding.pry
      ## Returns nothing.  Sent to @crm_data
    end


    ## Returns args that match permitted names and types if arg value not nil.
    def get_path_hash_url_args(args={})
      args_hash = args.delete_if {|k,v| !v.present? }
      allowed_arg_kvs = {file_path: 'string', hashes: 'array', arrays: 'array'}
      permitted_arg_keys = check_args_name_and_class(allowed_arg_kvs, args_hash)
      permitted_arg = args_hash.select { |k,v| permitted_arg_keys.include?(k) }
    end


    ## Returns keys of the args with allowed key name and value type if arg value not nil.
    def check_args_name_and_class(allowed_arg_kvs, args_hash)
      if allowed_arg_kvs&.any? && args_hash&.any?
        passed_keys = args_hash.keys & allowed_arg_kvs.keys

        if passed_keys.any?
          passed_arg_kvs = passed_keys.map do |key|
            arg_val = args_hash[key]
            allowed_type = allowed_arg_kvs[key]
            arg_val.is_a?(allowed_type.classify.constantize) ? key : nil
          end
        end
      end
      passed_arg_kvs&.any? ? passed_arg_kvs : nil
    end


    def get_args
      neg_urls = %w(approv avis budget collis eat enterprise facebook financ food google gourmet hertz hotel hyatt insur invest loan lube mobility motel motorola parts quick rent repair restaur rv ryder service softwar travel twitter webhost yellowpages yelp youtube)

      pos_urls = ["acura", "alfa romeo", "aston martin", "audi", "bmw", "bentley", "bugatti", "buick", "cdjr", "cadillac", "chevrolet", "chrysler", "dodge", "ferrari", "fiat", "ford", "gmc", "group", "group", "honda", "hummer", "hyundai", "infiniti", "isuzu", "jaguar", "jeep", "kia", "lamborghini", "lexus", "lincoln", "lotus", "mini", "maserati", "mazda", "mclaren", "mercedes-benz", "mitsubishi", "nissan", "porsche", "ram", "rolls-royce", "saab", "scion", "smart", "subaru", "suzuki", "toyota", "volkswagen", "volvo"]

      neg_links = %w(: .biz .co .edu .gov .jpg .net // afri anounc book business buy bye call cash cheap click collis cont distrib download drop event face feature feed financ find fleet form gas generat graphic hello home hospi hour hours http info insta inventory item join login mail mailto mobile movie museu music news none offer part phone policy priva pump rate regist review schedul school service shop site test ticket tire tv twitter watch www yelp youth)

      neg_hrefs = %w(? .com .jpg @ * afri after anounc apply approved blog book business buy call care career cash charit cheap check click collis commerc cont contrib deal distrib download employ event face feature feed financ find fleet form gas generat golf here holiday hospi hour info insta inventory join later light login mail mobile movie museu music news none now oil part pay phone policy priva pump quick quote rate regist review saving schedul service shop sign site speci ticket tire today transla travel truck tv twitter watch youth)

      neg_exts = %w(au ca edu es gov in ru uk us)
      # oa_args = {neg_urls: neg_urls, pos_urls: pos_urls, neg_exts: neg_exts}
      oa_args = {neg_exts: neg_exts}
    end


    ### Sample Hashes for validate_data
    def get_seed_hashes
      [{:row_id=>1,
        :url=>"stanleykaufman.net",
        :act_name=>"Stanley Chevrolet Kaufman",
        :street=>"825 E Fair St",
        :city=>"Kaufman",
        :state=>"TX",
        :zip=>"75142",
        :phone=>"(888) 457-4391"},
       {:row_id=>2,
        :url=>"leepartyka.com",
        :act_name=>"Lee Partyka Chevrolet Mazda Isuzu Truck",
        :street=>"200 Skiff St",
        :city=>"Hamden",
        :state=>"CT",
        :zip=>"6518",
        :phone=>"(203) 288-7761"},
       {:row_id=>3,
        :url=>"burienhonda.com",
        :act_name=>"Honda of Burien 15026 1st Avenue South, Burien, WA 98148",
        :street=>"15026 1st Avenue South",
        :city=>"Burien",
        :state=>"WA",
        :zip=>"98148",
        :phone=>"(206) 246-9700"},
       {:row_id=>4,
        :url=>"cortlandchryslerdodgejeep.com",
        :act_name=>"Cortland Chrysler Dodge Jeep RAM",
        :street=>"3878 West Rd",
        :city=>"Cortland",
        :state=>"NY",
        :zip=>"13045",
        :phone=>"(877) 279-3113"},
       {:row_id=>5,
        :url=>"imperialmotors.net",
        :act_name=>"Imperial Motors",
        :street=>"4839 Virginia Beach Blvd",
        :city=>"Virginia Beach",
        :state=>"VA",
        :zip=>"23462",
        :phone=>"(757) 490-3651"},
       {:row_id=>6,
        :url=>"liatoyotaofnorthampton.com",
        :act_name=>"Lia Toyota of Northampton 280 King St. Northampton, MA 01060 Phone 413-341-5299",
        :street=>"280 King St",
        :city=>"Northampton",
        :state=>"MA",
        :zip=>"1060",
        :phone=>"(413) 341-5299"},
       {:row_id=>7,
        :url=>"nelsonhallchevrolet.com",
        :act_name=>"Nelson Hall Chevrolet",
        :street=>"1811 S Frontage Rd",
        :city=>"Meridian",
        :state=>"MS",
        :zip=>"39301",
        :phone=>"(601) 621-4593"},
       {:row_id=>8,
        :url=>"marshallfordco.com",
        :act_name=>"Marshall Ford Co Inc.",
        :street=>"14843 MS-16",
        :city=>"Philadelphia",
        :state=>"MS",
        :zip=>"39350",
        :phone=>"(888) 461-7643"},
       {:row_id=>9,
        :url=>"warrentontoyota.com",
        :act_name=>"Warrenton Toyota",
        :street=>"6449 Lee Hwy",
        :city=>"Warrenton",
        :state=>"VA",
        :zip=>"20187",
        :phone=>"(540) 878-4100"},
       {:row_id=>10,
        :url=>"toyotacertifiedatcentralcity.com",
        :act_name=>"Toyota Certified Central City",
        :street=>"4800 Chestnut St",
        :city=>"Philadelphia",
        :state=>"PA",
        :zip=>"19139",
        :phone=>"(888) 379-1155"}]
    end












  #   def self.utf_cleaner(string)
  #     binding.pry
  #     if string.present?
  #       string = string&.gsub(/\s/, ' ')&.strip ## Removes carriage returns and new lines.
  #       string = validate_encoding(string) ## Removes non-utf8 chars.
  #       return string
  #     end
  #   end
  #
  #
  #   def self.validate_encoding(text)
  #     binding.pry
  #     # text = "Ã¥ÃŠÃ¥Â©team auto solutions"
  #     # text = "Ã¥ÃŠÃ¥ÃŠÃ¥ÃŠour staff"
  #     clean_text = text.delete("^\u{0000}-\u{007F}")
  #     clean_text = clean_text.gsub(/\s+/, ' ')
  #
  #     binding.pry
  #     return clean_text
  #   end
  #
  #   ##########
  #
  #
  #
  # def self.validate_csv
  #   counter = 0
  #   error_row_numbers = []
  #   clean_csv_hashes = []
  #   headers = []
  #   rows = []
  #
  #   file_path = "./lib/crm_formatter/seeds.csv"
  #
  #   File.open(file_path).each do |line|
  #     binding.pry
  #     begin
  #       line_1 = line&.gsub(/\s/, ' ')&.strip ## Removes carriage returns and new lines.
  #       line_2 = validate_encoding(line_1) ## Removes non-utf8 chars.
  #
  #       CSV.parse(line_2) do |row|
  #         row = row.collect { |x| x.try(:strip) } ## Strips white space from each el in row array.
  #
  #         if counter > 0
  #           clean_csv_hashes << row_to_hsh(row)
  #           rows << row
  #         else
  #           headers = row
  #         end
  #         counter += 1
  #       end
  #     rescue => er
  #       error_row_numbers << {"#{counter}": "#{er.message}"}
  #       counter += 1
  #       next
  # #     end
  # #   end
  #
  #
  #   binding.pry
  #   clean_csv_hashes
  #   # error_report(error_row_numbers)
  #   # return @clean_csv_hashes
  # end
  #






    ################################################


    def self.export(hash)
      binding.pry

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
