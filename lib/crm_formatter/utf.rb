require "csv"

module CrmFormatter
  class UTF

    # args = {seed_non_utfs: false, seed_hashes: false, seed_csv: false}
    def initialize(args={})
      binding.pry
      @utf_result = { stats: {}, data: {} }
      @valid_rows, @defective, @errors, @encoded = [], [], [], []
      @headers = []
      @row_id = 0
      # @seed_non_utfs = true
      # @seed_hashes = true
      # @seed_csv = true
      @seed_non_utfs = args.fetch(:seed_non_utfs, false)
      @seed_hashes = args.fetch(:seed_hashes, false)
      @seed_csv = args.fetch(:seed_csv, false)
    end

    #################### * VALIDATE DATA * ####################
    ## Only accepts 1 arg, w/ either 2 key symbols:  :file_path OR :hashes.
    def validate_data(args={})
      arg_key = args.compact.keys.first
      arg_val = args.compact.values.first

      if @seed_hashes
        validate_hashes(get_seed_hashes)
      elsif @seed_csv
        validate_csv(get_seed_file_path)
      elsif arg_key
        file_path = args.fetch(:file_path)

        binding.pry
      else
        binding.pry
      end
      binding.pry


      if arg.is_a?(String) && arg.include?(".csv")
        utf_result = validate_csv(arg)
        binding.pry
      elsif arg.is_a?(Array) && arg.first.is_a?(Hash)
        binding.pry
      end

      binding.pry



      # file_path = arg.fetch(:file_path, {})
      # utf_result = arg.fetch(:data_hashes, {}) if utf_result.empty?


      # utf_result = validate_csv(arg[:file_path])
      binding.pry
      utf_result = validate_hashes(arg[:data_hashes]) if !utf_result.present?
      binding.pry

      # file_path = arg[:file_path]
      # data_hashes = arg[:data_hashes]
      # utf_result = validate_csv(file_path) if file_path
      # utf_result = validate_hashes(data_hashes) if data_hashes

      # file_path = arg[:file_path]
      # data_hashes = arg[:data_hashes]




      # if file_path
      #   utf_result = validate_csv(file_path)
      # elsif data_hashes
      #   utf_result = validate_hashes(data_hashes)
      # else
      #   binding.pry
      #   utf_result = {}
      # end
      # utf_result

      # data_hash_key = arg.keys.first
      # data_hash_val = arg.values.first

      # if data_hash_key == :file_path
      #   utf_result = validate_csv(data_hash_val)
      # elsif data_hash_key == :hashes
      #   utf_result = validate_hashes(data_hash_val)
      # else
      #   utf_result = {}
      # end
      # utf_result
    end
    #################### * VALIDATE DATA * ####################

    #################### * COMPILE RESULTS * ####################
    def compile_results
      details = @valid_rows.map { |hsh| hsh[:details] }
      mapped_details = details.map { |str| str.split(', ') }.flatten.compact
      groups = make_groups_from_array(mapped_details)
      wchar = groups['wchar']
      perfect = groups['perfect']

      stats = {total: @row_id, valid: @valid_rows.count, invalid: @defective.count, perfect: perfect, encoded: @encoded.count, wchar: wchar }
      data = {valid_rows: @valid_rows, defective: @defective, errors: @errors}
      @utf_result = { stats: stats, data: data }
      return @utf_result
    end
    #################### * COMPILE RESULTS * ####################

    #################### * VALIDATE CSV * ####################
    def validate_csv(file_path)
      File.open(file_path).each do |file_line|
        begin
          validated_line = utf_filter(check_utf(file_line))
          @row_id +=1
          if validated_line
            CSV.parse(validated_line) do |row|
              if @headers.empty?
                @headers = row
              else
                @data_hash.merge!(row_to_hsh(row))
                @valid_rows << @data_hash
              end
            end
          end
        rescue => er
          binding.pry
        end
      end

      compile_results ## Calls method to handle returns.
    end
    #################### * VALIDATE CSV * ####################

    #################### * VALIDATE HASHES * ####################
    def validate_hashes(orig_hashes)
      begin
        process_hash_row(orig_hashes.first) ## re keys for headers.
        orig_hashes.each { |hsh| process_hash_row(hsh) } ## re values
      rescue => er
        binding.pry
      end
      compile_results ## handles returns.
    end

    ### process_hash_row - helper VALIDATE HASHES ###
    ### Converts hash keys and vals into parsed line.
    def process_hash_row(hsh)
      if @headers.any?
        keys_or_values = hsh.values
        @row_id = hsh[:row_id]
      else
        keys_or_values = hsh.keys.map(&:to_s)
      end

      file_line = keys_or_values.join(",")
      line_parse(utf_filter(check_utf(file_line)))
    end

    ### line_parse - helper VALIDATE HASHES ###
    ### Parses line to row, then updates final results.
    def line_parse(validated_line)
      if validated_line
        row = validated_line.split(',')
        if row.any?
          if @headers.empty?
            @headers = row
          else
            @data_hash.merge!(row_to_hsh(row))
            @valid_rows << @data_hash
          end
        end
      end
    end
    #################### * VALIDATE HASHES * ####################


    #################### * CHECK UTF * ####################
    def check_utf(text)
      text = seed_non_utfs(text) if @seed_non_utfs && @headers.any?
      results = {text: text, encoded: nil, wchar: nil, error: nil}
      begin
        if !text.valid_encoding?
          encoded = text.chars.select(&:valid_encoding?).join
          encoded.gsub!('_', '')
          encoded = encoded.delete("^\u{0000}-\u{007F}")
        else
          encoded = text.delete("^\u{0000}-\u{007F}")
        end

        wchar = encoded&.gsub(/\s+/, ' ')&.strip
        results[:encoded] = encoded if text != encoded
        results[:wchar] = wchar if encoded != wchar
      rescue=>e
        results[:error] = e.message if e.message.present?
        binding.pry
      end

      results
    end
    #################### * CHECK UTF * ####################


    #################### * UTF FILTER * ####################
    def utf_filter(utf)
      puts utf.inspect
      details = utf.except(:text).compact.keys
      details = details&.map(&:to_s).join(', ')
      details = 'perfect' if details.blank?

      encoded = utf[:text] if utf[:encoded]
      error = utf[:error]
      defective = utf[:text] if error
      line = utf.except(:error).compact.values.last if !error
      data_hash = {row_id: @row_id, details: details}

      @encoded << {row_id: @row_id, text: encoded} if encoded
      @errors << {row_id: @row_id, text: error} if error
      @invalid_text << filt_utf_hsh[:text] if error

      if !@data_hash || @data_hash[:row_id] != @row_id
        @data_hash = data_hash
      end

      line
    end
    #################### * UTF FILTER * ####################



    #################### !! HELPERS BELOW !! ####################
    #############################################################
    def seed_non_utfs(text)
      list = ["h∑", "lÔ", "\x92", "\x98", "\x99", "\xC0", "\xC1", "\xC2", "\xCC", "\xDD", "\xE5", "\xF8"]
      index = text.length / 2
      var = "#{list.sample}_#{list.sample}"
      text.insert(index, var)
      text.insert(-1, "\r\n")
      text
    end

    ############# KEY VALUE CONVERTERS #############
    def row_to_hsh(row)
      h = Hash[@headers.zip(row)]
      h.symbolize_keys
    end

    def val_hsh(cols, hsh)
      keys = hsh.keys
      keys.each { |key| hsh.delete(key) if !cols.include?(key) }
      hsh
    end

    def make_groups_from_array(array)
      groups = array.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }
    end

    #########################################################################################################
    ### MIGHT NOT USE, BUT SAVE FOR LATER IN CASE NEEDED
    #########################################################################################################
      # def compare_diff(hsh)
      #   res = []
      #   hsh.to_a.reduce do |el, nxt|
      #     res << nxt.first if el.last != nxt.last
      #     el = nxt
      #   end
      #   res.compact!
      # end
    #########################################################################################################
    ### SAMPLE OF HOW TO CONVERT HASH INTO DOT NOTATION, BUT ONLY IF THERE IS A MODEL.:
    #########################################################################################################
      # # getter
      #     ['row_id', 'type_id', 'status'].each do |key|
      #       define_method key do
      #         data_hash[key]
      #       end
      #     end
      #
      #
      # # setter
      #     ['row_id', 'type_id', 'status'].each do |key|
      #       define_method key do |val|
      #         data_hash[key] = val
      #       end
      #     end
      #     # data_hash.row_id
      #     # data_hash.row_id = 'gh'
    #########################################################################################################
    ###  CAN RUN BELOW TO GRAB A BUNCH OF NON-UTF8 STRINGS TO TEST check_utf METHOD.
    #########################################################################################################
    # defective = get_non_utf_seeds ## For testing.  Returns array of non-utf8
    def get_non_utf_seeds ## For testing UTF8 Validator
      strings = []
      strings << "2,heritagemazdatowson.com,Heritage Mazda Towson,1630 York Rd_\xED\xBF\x8Cˌ_\xED\xEE\xE4\xF3\xC1\xED_\x8C\xE7_\xED\xBF\x8Cˌ___\xED\xBF\x8Cˌ_\xED\xBF\x8Cˌ__,Lutherville,MD,21093,(877) 361-1038\r\n"
      strings += ["𝘀𝔞ｍϱl𝔢", "xC2", "hellÔ!", "hi∑", "hi\x99!", "foo\x92bar"]
      # str_arr += %w(𝘀𝔞ｍϱl𝔢 xC2 hellÔ! hi∑ hi\x99! foo\x92bar)

      ### TRIALS WITH UTF8 BELOW.  IF EVER HAVE A TOUGH ONE, USE THESE NOTES AGAIN.  ###
      # best1 = text.chars.select(&:valid_encoding?).join
      # best2 = text.chars.map{|c| c.valid_encoding? ? c : " "}.join
      # best3 = text.scrub
      # best4 = text.encode('UTF-8', invalid: :replace, undef: :replace)
      # best5 = text.encode("UTF-8", "Windows-1252", invalid: :replace, undef: :replace)
      # best6 = text.encode('utf-16', invalid: :replace).encode('utf-8')
      # best7 = text.encode('utf-8', invalid: :replace)
      # fail = text.encode("ISO-8859-1"); str.encode("UTF-8")
      # fail = text.force_encoding("ISO-8859-5"); str.encode("UTF-8")
      # clean5.gsub!('_', '')
      # clean5.gsub!('ˌ', '')
      # puts clean5.inspect
      # 'ˌ'.class => String
      # 'ˌ'.bytes => [203, 140]
      # [203, 140].pack('c*')
      # myst2 = [203, 140].pack('c*').chars.select(&:valid_encoding?).join
      # cl = [203, 140].pack('c*').encode("UTF-8", "ASCII-8BIT", invalid: :replace, undef: :replace)
      # cl = [203, 140].pack('c*').encode("UTF-8", "Windows-1252", invalid: :replace, undef: :replace)
      strings
    end
    #########################################################################################################
    #########################################################################################################



    #########################################################################################################
    ######## Redoing validate_hashes Above.  keep this to reference till done.
    #########################################################################################################
    # def orig_validate_hashes(orig_hashes)
    #   headers, val_hshs, inval_rows = [], [], []
    #
    #   row_num = 0
    #   dif_count = 0
    #   err_rows = []
    #
    #   new_orig_hashes = orig_hashes.map do |hsh|
    #     clean_hsh = hsh.each do |el|
    #       key = el.first
    #       val = el.last
    #
    #       val2 = check_utf(val)
    #       hsh[key] = val2
    #       err_rows << [row_num, key] if val2 != val
    #     end
    #
    #     row_num +=1
    #     clean_hsh
    #   end
    #
    #   puts err_rows.inspect
    #
    #   err_rows.each do |err_row|
    #     puts new_orig_hashes[err_row.first].inspect
    #     puts orig_hashes[err_row.first].inspect
    #   end
    #   compile_results ## Calls method to handle returns.
    # end
    #########################################################################################################
    #########################################################################################################

    def get_seed_file_path
      # "./lib/crm_formatter/csv/seeds_clean.csv"
      # "./lib/crm_formatter/csv/seeds_dirty.csv"
      # "./lib/crm_formatter/csv/seeds_mega.csv"
      # "./lib/crm_formatter/csv/seeds_mini.csv"
      "./lib/crm_formatter/csv/seeds_mini_10.csv"
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



  end

end
