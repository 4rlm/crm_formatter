require "csv"

module CrmFormatter
  class UTF

    def initialize
      @utf_result = { stats: {}, data: {} }
      @valid_rows, @defective, @errors, @encoded = [], [], [], []
      @headers = []
      @row_id = 0
      @insert_non_utf = false
    end

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

    #################### * VALIDATE DATA * ####################
    ## Accepted arg keys & values: either :file_path, :arrays, or :hashes.
    ## First entry point for UTF, then distributes to 3 diff meth options based on arg name and type.
    ## Only accepts 1 arg, even though arg.keys / arg.values being used!
    def validate_data(arg)
      encoding_details = 'Error: Empty args sent to validate_data!'
      return encoding_details unless arg&.values&.present?
      arg_key = arg.keys.first
      arg_val = arg.values.first

      if arg_key == :file_path
        utf_result = validate_csv(arg_val)
        # arg_val = utf_result[:data][:valid_rows]
        # arg_val = arg_val.map { |hsh| hsh.except(:details) }
        # initialize
        # utf_result = nil
        # utf_results = validate_hashes(arg_val)
        # binding.pry
      elsif arg_key == :hashes
        utf_results = validate_hashes(arg_val)
        binding.pry
      elsif arg_key == :arrays
        utf_results = validate_arrays(arg_val)
      else
        utf_results = {}
      end
    end
    #################### * VALIDATE DATA * ####################


    ########## VALIDATE ARRAYS ##########
    def validate_arrays(orig_arrays)
      headers, val_hshs, inval_rows = [], [], []
      ## Not created yet.
      binding.pry
      compile_results ## Calls method to handle returns.
    end


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
      text = insert_non_utf(text) if @insert_non_utf && @headers.any?
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
    def insert_non_utf(text)
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



  end

end
