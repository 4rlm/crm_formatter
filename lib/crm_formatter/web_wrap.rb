require 'csv'

module CrmFormatter
  module WebWrap

    # web_wrap = CrmFormatter::WebWrap.new
    # web_wrap.hello

    def self.wrap
      # binding.pry
      run_format_url
    end


    def self.run_format_url
      # binding.pry
      # parse_csv

      parser = CrmFormatter::Parser.new
      parsed = parser.parse_csv
      binding.pry
      # import
      # web = CrmFormatter::Web.new
      # url = 'grossingertoyota.com'
      # url_hsh = web.format_url(url)

      # web = self::Web.new(get_args)
      # urls = get_urls

      # formatted_url_hashes = urls.map do |url|
      #   url_hash = web.format_url(url)
      # end
      #
      # formatted_url_hashes
    end


    def self.import(args={})
      # args.respond_to?(:to_s)
      # arg_info = args.delete_if
      # arg_info = args.delete_if {|k, v| !v.present? }

      file_path = "./lib/crm_formatter/seeds.csv"
      binding.pry

      # seeds = CSV.read(file_path).flatten.map do |row|
      CSV.read(file_path).map do |row|
        binding.pry
        utf_cleaner(row)
        binding.pry
      end

      binding.pry
      # seeds.map { |e| binding.pry if e }

    end


  #   def self.utf_cleaner(string)
  #     binding.pry
  #     if string.present?
  #       string = string&.gsub(/\s/, ' ')&.strip ## Removes carriage returns and new lines.
  #       string = force_utf_encoding(string) ## Removes non-utf8 chars.
  #       return string
  #     end
  #   end
  #
  #
  #   def self.force_utf_encoding(text)
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
  # def self.parse_csv
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
  #       line_2 = force_utf_encoding(line_1) ## Removes non-utf8 chars.
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
