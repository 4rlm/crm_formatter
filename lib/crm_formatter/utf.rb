require "csv"

module CrmFormatter
  class UTF

    # args = {pollute_seeds: false, seed_hashes: false, seed_csv: false}
    def initialize(args={})
      @utf_result = { stats: {}, data: {} }
      @valid_rows, @encoded_rows, @defective_rows, @error_rows = [], [], [], []
      @headers = []
      @row_id = 0
      @data_hash = {}
      @pollute_seeds = args.fetch(:pollute_seeds, false)
      @seed_hashes = args.fetch(:seed_hashes, false)
      @seed_csv = args.fetch(:seed_csv, false)
    end

    #################### * VALIDATE DATA * ####################
    ## Only accepts 1 arg, w/ either 2 key symbols:  :file_path OR :hashes.
    def validate_data(args={})
      if args.present?
        if @seed_hashes
          utf_result = validate_hashes(get_seed_hashes)
        elsif @seed_csv
          utf_result = validate_csv(get_seed_file_path)
        else
          file_path = args[:file_path]
          utf_result = validate_csv(file_path) if file_path
          data = args[:data]
          utf_result = validate_hashes(data) if data
        end
        utf_result
      end
    end
    #################### * VALIDATE DATA * ####################

    #################### * COMPILE RESULTS * ####################
    def compile_results
      utf_status = @valid_rows.map { |hsh| hsh[:utf_status] }
      mapped_details = utf_status.map { |str| str.split(', ') }.flatten.compact
      groups = make_groups_from_array(mapped_details)
      wchar = groups['wchar']
      perfect = groups['perfect']

      @headers.any? ? header_row_count = 1 : header_row_count = 0
      stats = {total_rows: @row_id, header_row: header_row_count, valid_rows: @valid_rows.count, error_rows: @error_rows.count, defective_rows: @defective_rows.count, perfect_rows: perfect, encoded_rows: @encoded_rows.count, wchar_rows: wchar }
      data = {valid_data: @valid_rows, encoded_data: @encoded_rows, defective_data: @defective_rows, error_data: @error_rows}
      @utf_result = { stats: stats, data: data }
      utf_result = @utf_result
      initialize
      return utf_result
    end
    #################### * COMPILE RESULTS * ####################

    #################### * VALIDATE CSV * ####################
    def validate_csv(file_path)
      if file_path.present?
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
          rescue => error
            @error_rows << {row_id: @row_id, text: error.message}
          end
        end
        compile_results
      end
    end
    #################### * VALIDATE CSV * ####################

    #################### * VALIDATE HASHES * ####################
    def validate_hashes(orig_hashes)
      if orig_hashes.present?
        begin
          process_hash_row(orig_hashes.first) ## re keys for headers.
          orig_hashes.each { |hsh| process_hash_row(hsh) } ## re values
        rescue => error
          @error_rows << {row_id: @row_id, text: error.message}
        end
        compile_results ## handles returns.
      end
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
      if text.present?
        text = pollute_seeds(text) if @pollute_seeds && @headers.any?
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
        rescue=> error
          results[:error] = error.message if error
        end
        results
      end
    end
    #################### * CHECK UTF * ####################


    #################### * UTF FILTER * ####################
    def utf_filter(utf)
      if utf.present?
        puts utf.inspect
        utf_status = utf.except(:text).compact.keys
        utf_status = utf_status&.map(&:to_s).join(', ')
        utf_status = 'perfect' if utf_status.blank?

        encoded = utf[:text] if utf[:encoded]
        error = utf[:error]
        defective = utf[:text] if error
        line = utf.except(:error).compact.values.last if !error
        data_hash = {row_id: @row_id, utf_status: utf_status}

        @encoded_rows << {row_id: @row_id, text: encoded} if encoded
        @error_rows << {row_id: @row_id, text: error} if error
        @defective_rows << filt_utf_hsh[:text] if error
        @data_hash = data_hash if @data_hash[:row_id] != @row_id
        line
      end
    end
    #################### * UTF FILTER * ####################



    #################### !! HELPERS BELOW !! ####################
    #############################################################
    def pollute_seeds(text)
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
    ###################################################################################
    ###################################################################################

    def get_seed_file_path
      # "./lib/crm_formatter/csv/seeds_clean.csv"
      # "./lib/crm_formatter/csv/seeds_dirty.csv"
      # "./lib/crm_formatter/csv/seeds_mega.csv"
      # "./lib/crm_formatter/csv/seeds_mini.csv"
      # "./lib/crm_formatter/csv/seeds_mini_10.csv"
      "./lib/crm_formatter/csv/seeds_mini_2_bug.csv"
    end

    ### Sample Hashes for validate_data
    def get_seed_hashes
      [{:row_id=>1,
        :url=>"stanleykaufman.com",
        :act_name=>"Stanley Chevrolet Kaufman",
        :street=>"825 E Fair St",
        :city=>"Kaufman",
        :state=>"TX",
        :zip=>"75142",
        :phone=>"(888) 457-4391"},
       {:row_id=>2,
        :url=>"leepartyka",
        :act_name=>"Lee Partyka Chevrolet Mazda Isuzu Truck",
        :street=>"200 Skiff St",
        :city=>"Hamden",
        :state=>"CT",
        :zip=>"6518",
        :phone=>"(203) 288-7761"},
       {:row_id=>3,
        :url=>"burienhonda.fake.not.net.com",
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
