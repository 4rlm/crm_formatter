require 'csv'

module CrmFormatter
  class WebWrap

    def initialize
      utf_args = {pollute_seeds: true, seed_hashes: false, seed_csv: false}
      @utf = CrmFormatter::UTF.new(utf_args)
      @crm_data = []
      # @crm_data[:data][:valid_data] ## path to 'valid data'
      # @crm_data[:stats] ## path to 'stats'
    end

    def wrap
      formatted_urls = format_urls
      binding.pry if formatted_urls.any?
      formatted_urls
    end


    def format_urls(args={})
      import_data(args={}) ## data sent to @crm_data
      valid_data = @crm_data[:data][:valid_data]

      if valid_data&.any?
        web = CrmFormatter::Web.new(get_web_args)
        puts "\n\n\n\n===============================================\n\n\n\n"

        formatted_data = valid_data.map do |valid_hash|
          formatted_hash = web.format_url(valid_hash[:url])
          formatted_hash2 = valid_hash.merge(formatted_hash)
          puts "\n----------------------------------------"
          puts valid_hash.inspect
          puts "\n----------------------------------------"
          puts formatted_hash.inspect
          puts "\n----------------------------------------"
          puts formatted_hash2.inspect
          puts "\n----------------------------------------"
          binding.pry

          formatted_hash2
        end
        puts "\n\n=========================================\n\n"
        puts formatted_data.inspect
        binding.pry

        formatted_data
      else
        binding.pry
      end
    end


    ## Accepted arg keys & values: either :file_path, or :hashes.
    def import_data(args={})
      args = {file_path: @utf.get_seed_file_path}
      # args = {data: @utf.get_seed_hashes}
      @crm_data = @utf.validate_data(args)
    end


    def get_web_args
      neg_urls = %w(approv avis budget collis eat enterprise facebook financ food google gourmet hertz hotel hyatt insur invest loan lube mobility motel motorola parts quick rent repair restaur rv ryder service softwar travel twitter webhost yellowpages yelp youtube)

      pos_urls = ["acura", "alfa romeo", "aston martin", "audi", "bmw", "bentley", "bugatti", "buick", "cdjr", "cadillac", "chevrolet", "chrysler", "dodge", "ferrari", "fiat", "ford", "gmc", "group", "group", "honda", "hummer", "hyundai", "infiniti", "isuzu", "jaguar", "jeep", "kia", "lamborghini", "lexus", "lincoln", "lotus", "mini", "maserati", "mazda", "mclaren", "mercedes-benz", "mitsubishi", "nissan", "porsche", "ram", "rolls-royce", "saab", "scion", "smart", "subaru", "suzuki", "toyota", "volkswagen", "volvo"]

      neg_links = %w(: .biz .co .edu .gov .jpg .net // afri anounc book business buy bye call cash cheap click collis cont distrib download drop event face feature feed financ find fleet form gas generat graphic hello home hospi hour hours http info insta inventory item join login mail mailto mobile movie museu music news none offer part phone policy priva pump rate regist review schedul school service shop site test ticket tire tv twitter watch www yelp youth)

      neg_hrefs = %w(? .com .jpg @ * afri after anounc apply approved blog book business buy call care career cash charit cheap check click collis commerc cont contrib deal distrib download employ event face feature feed financ find fleet form gas generat golf here holiday hospi hour info insta inventory join later light login mail mobile movie museu music news none now oil part pay phone policy priva pump quick quote rate regist review saving schedul service shop sign site speci ticket tire today transla travel truck tv twitter watch youth)

      neg_exts = %w(au ca edu es gov in ru uk us)
      # oa_args = {neg_urls: neg_urls, pos_urls: pos_urls, neg_exts: neg_exts}
      oa_args = {neg_exts: neg_exts}
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
