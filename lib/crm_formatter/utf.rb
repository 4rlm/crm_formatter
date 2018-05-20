require "csv"

module CrmFormatter
  class UTF

    def initialize
      @utfs = [{ stats: {}, data_hashes: [], invalid_data: [], errors: [] }]
      @stats = {rows: 0, valid: 0, invalid: 0, encoded_text: 0, wchar_text: 0 }
      @data_hashes, @invalid_data, @errors = [], [], []
      @row_id = 0
    end


    def compile_results
      encoding_details = @data_hashes.map do |hsh|
        binding.pry
        if hsh[:valid_encoding] == true
          details = hsh[:encoding_details].split(', ')
        end
      end  ## should have nested arrays of encoding_details.  Will need to flatten, then group, then tally.  can use very bottom method for that.

      hsh_by_grp = make_groups_from_array(encoding_details.flatten)
      @was_utfs_need_move[:encoded_text] = encoding_details ## needs some work still
      @was_utfs_need_move[:wchar_text] = encoding_details ## needs some work still

      @utfs[:stats] = @stats
      @utfs[:was_utfs_need_move] = @was_utfs_need_move
      @utfs[:data_hashes] = @data_hashes
      return @utfs
    end


    def get_invals
      ## For testing.  Gets all inval text from results.
      headers = %w(act_name street city state zip phone)
      rows = @invalid_data.map{|row| row[:text]}
      inval_hsh = {headers: headers, rows: rows}
    end


    ## Accepted arg keys & values: either :file_path, :array_of_strings, or :array_of_hashes.
    ## First entry point for UTF, then distributes to 3 diff meth options based on arg name and type.
    ## Only accepts 1 arg, even though arg.keys / arg.values being used!
    def validate_data(arg)
      encoding_details = 'Error: Empty args sent to validate_data!'
      return encoding_details unless arg&.values&.present?
      arg_key = arg.keys.first
      arg_val = arg.values.first

      if arg_key == :file_path
        utf_results = validate_csv(arg_val)
      elsif arg_key == :array_of_hashes
        utf_results = validate_hashes(arg_val)
      elsif arg_key == :array_of_strings
        utf_results = validate_arrays(arg_val)
      else
        utf_results = {}
      end
    end


    ## Doesn't return anything. Updates Instance Variables for Reporting.
    def record_invals_and_errors(filt_utf_hsh)
      if filt_utf_hsh&.any?
        invalid_data = filt_utf_hsh[:invalid_data]
        errors = filt_utf_hsh[:errors]

        if invalid_data.any? || errors.any?
          invalid_data.map! {|el| {row_id: @row_id, text: el } }
          errors.map! {|el| {row_id: @row_id, text: el } }
          binding.pry if errors.any?
          @invalid_data += invalid_data
          @errors += errors
        end
      end
    end


    ########## VALIDATE CSV ##########
    def validate_csv(file_path)
      headers = []
      File.open(file_path).each do |line|
        begin
          @row_id +=1
          filt_utf_hsh = utf_filter(check_utf(line))
          record_invals_and_errors(filt_utf_hsh)
          line = filt_utf_hsh[:line]

          if line
            CSV.parse(line) do |row|
              if headers.empty?
                headers = row
              else
                @data_hash = filt_utf_hsh[:data_hash]
                @data_hash[:row_id] = @row_id
                @data_hash.merge!(row_to_hsh(row, headers))
                @data_hashes << @data_hash
              end
            end
          end
        rescue => er
          binding.pry
        end
      end

      puts @data_hashes.count
      binding.pry
      compile_results ## Calls method to handle returns.
    end


    ################# HERE - HERE #####################
    def utf_filter(utf)
      line = nil
      details, invalid_data, errors = [], [], []
      arrs = [details, invalid_data, errors]

      ### Filter ###
      details << utf.except(:text).compact.keys
      invalid_data << utf[:text] if utf[:encoded_text]
      errors << utf[:err_msg]
      line = utf.except(:err_msg).compact.values.last unless utf[:err_msg]
      utf[:err_msg] ? valid = false : valid = true

      ### Format Before Return ###
      arrs.map! do |arr|
        arr.flatten!
        arr.compact!
        arr.map!(&:to_s)
      end
      details = details.join(', ')

      ### Create Return Hashes ###
      data_hash = {row_id: nil, valid: valid, details: details}
      filt_utf_hsh = { line: line, data_hash: data_hash, invalid_data: invalid_data, errors: errors }
    end


    def check_utf(text)
      results = {text: text, encoded_text: nil, wchar_text: nil, err_msg: nil}
      begin
        if !text.valid_encoding?
          encoded_text = text.chars.select(&:valid_encoding?).join
          encoded_text.gsub!('_', '')
          encoded_text = encoded_text.delete("^\u{0000}-\u{007F}")
        else
          encoded_text = text.delete("^\u{0000}-\u{007F}")
        end

        wchar_text = encoded_text&.gsub(/\s+/, ' ')&.strip
        results[:encoded_text] = encoded_text if text != encoded_text
        results[:wchar_text] = wchar_text if encoded_text != wchar_text
      rescue=>e
        results[:err_msg] = e.message if e.message.present?
        binding.pry
      end
      results
    end


    ########## VALIDATE ARRAYS ##########
    def validate_arrays(orig_arrays)
      headers, val_hshs, inval_rows = [], [], []
      ## Not created yet.
      binding.pry
      compile_results ## Calls method to handle returns.
    end


    ########## VALIDATE HASHES ##########
    def validate_hashes(orig_hashes)
      binding.pry
      headers, val_hshs, inval_rows = [], [], []

      row_num = 0
      dif_count = 0
      err_rows = []

      new_orig_hashes = orig_hashes.map do |hsh|

        clean_hsh = hsh.each do |el|
          key = el.first
          val = el.last

          val2 = check_utf(val)
          hsh[key] = val2
          err_rows << [row_num, key] if val2 != val
        end

        row_num +=1
        clean_hsh
      end

      puts err_rows.inspect

      err_rows.each do |err_row|
        puts new_orig_hashes[err_row.first].inspect
        puts orig_hashes[err_row.first].inspect
      end
      compile_results ## Calls method to handle returns.
    end


    ############# KEY VALUE CONVERTERS #############
    def row_to_hsh(row, headers)
      h = Hash[headers.zip(row)]
      h.symbolize_keys
    end

    def val_hsh(cols, hsh)
      keys = hsh.keys
      keys.each { |key| hsh.delete(key) if !cols.include?(key) }
      hsh
    end


    #########################################################################################################
    ### MIGHT NOT USE, BUT SAVE FOR LATER IN CASE NEEDED
    #########################################################################################################
      # def make_groups_from_array(tally_arr)
      #   hsh_by_grp = tally_arr.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }
      #   hsh_by_grp
      # end

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
    # invalid_data = get_non_utf_seeds ## For testing.  Returns array of non-utf8
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


  end

end
