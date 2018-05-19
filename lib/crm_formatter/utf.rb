require "csv"

module CrmFormatter
  class UTF

    def initialize
      @utfs = [{ stats: {}, dhs: [] }]
      @stats = {rows: 0, valid: 0, invalid: 0, encoded_text: 0, wchar_text: 0 }
      @dhs = []  ### dhs is short for dhs
      # @was_utfs_need_move = { non_utfs: [] }
      ## Send incoming data here, then just update it through here.
      ## After completing processes, XXX method will be called, which will shovel 1 - @stats, 2 - @was_utfs_need_move, 3 - @data_rows into @utfs
      # @row_id = 0
    end


    def compile_results
      ### !!! Needs to calculate stats from @dhs regarding valid and invalid hashes, which will be stored inside each hash.
      ## Run method to iterate @dhs grabbing each :encoding_details for: encoded_text, wchar_text, then count each and assign total count to @was_utfs_need_move
      binding.pry

      ######################################################
      ### NEED TO FINISH THIS ALGO HERE, THEN MOVE IT TO ITS OWN METHOD, BUT CALL IT FROM IN HERE.
      encoding_details = @dhs.map do |hsh|
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
      @utfs[:dhs] = @dhs
      binding.pry
      ######################################################

      ### If all saved properly:
      ### 1. Try to query over the data.
      ### 2. Then return @utfs, so it can be accessed by web_wrap, adr_wrap, or phone_wrap.
      ### 3. Zero out stats: {}, was_utfs_need_move: {}, dhs: [] so they can be used again without needing to initialize again.

      ###### PROBABLY DON'T NEED THESE BELOW.  WAIT TILL LATER TO SEE.  ######
      # utf_report = { valid: val_hshs.count,
      #   invalid: inval_rows.length,
      #   valid_details: make_groups_from_array(@encoding_report),
      #   invalid_details: inval_rows.each_with_index { |hsh, i| "#{i+1}) Row #{hsh.keys[0]}: #{hsh.values[0]}." }
      # }
      # utf_results = { utf_report: utf_report, valid_csv_hashes: val_hshs }

      return @utfs
    end

    def make_groups_from_array(tally_arr)
      binding.pry
      hsh_by_grp = tally_arr.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }
      binding.pry
      hsh_by_grp
    end


    ## Accepted arg keys & values: either :file_path, :array_of_strings, or :array_of_hashes.
    ## First entry point for UTF, then distributes to 3 diff meth options based on arg name and type.
    def validate_data(arg)
      ## Only accepts 1 arg, even though arg.keys / arg.values being used!
      encoding_details = 'Error: Empty args sent to validate_data!'
      return encoding_details unless arg&.values&.present?

      arg_key = arg.keys.first
      arg_val = arg.values.first

      if arg_key == :file_path
        utf_results = validate_csv(arg_val)
        binding.pry
        # compile_results
      elsif arg_key == :array_of_hashes
        utf_results = validate_hashes(arg_val)
        binding.pry
        # compile_results
      elsif arg_key == :array_of_strings
        utf_results = validate_arrays(arg_val)
        binding.pry
        # compile_results
      else
        utf_results = {}
      end

      ###### TESTING BELOW ########
      # SENDING RETURNED validate_csv THROUGH validate_hashes
      binding.pry
      sample_hashes = utf_results[:valid_csv_hashes]

      utf_results = validate_hashes(sample_hashes)
      binding.pry
      ###### TESTING ABOVE ########

      # utf_results
    end
    ########################### HERE ###########################

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
    ##################################################


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

      binding.pry
      puts err_rows.inspect

      err_rows.each do |err_row|
        binding.pry
        puts new_orig_hashes[err_row.first].inspect
        puts orig_hashes[err_row.first].inspect
        binding.pry
      end

      binding.pry
      orig_hashes

      # puts "dif_count: #{dif_count}"
      # puts "counter: #{counter}"
      # puts "@was_utfs_need_move: #{@was_utfs_need_move.count}"
      # binding.pry

      # utf_results = compile_results(inval_rows, val_hshs)
      compile_results ## Calls method to handle returns.
    end



    ########## VALIDATE CSV ##########
    def validate_csv(file_path)
      headers, val_hshs, inval_rows = [], [], []
      File.open(file_path).each do |line|
        begin
          line = check_utf(line)
          binding.pry if !line.valid_encoding?
          # @row_id +=1 unless headers.empty?
          # @row_id +=1
          # line = result[:text]
          ### Try to strip :text from result hash, to 'line', then 'merge' 'result' to 'dh'
          # result = {text: text, row_id: row_id, valid_encoding: false, encoding_details: [] }
          # result = {:text => :A, :b => :B, :c => :C, :d => :D}
          # line = result.slice(:text)
          CSV.parse(line) do |row|
            headers = row if headers.empty?

            if headers.any?
              @dh = {row_id: @dhs.length +1 }

              binding.pry
              @row_id +=1
              # dh = {row_id: @row_id, valid_encoding: true, encoding_details: nil }
              dh.merge!(row_to_hsh(row, headers))
              #DELETE=> after testing above.
              # puts dh.inspect

              ## Need to include validation data in each row hash.
              binding.pry
              @dhs << dh
              # val_hshs << row_to_hsh(row, headers)
            end
            @dhs << @dh
          end
        rescue => er
          puts er.message
          binding.pry
          # @row_id = rescue_row_id if rescue_row_id.present?
          # binding.pry if rescue_row_id.present?
          ## CONSIDER KEEPING RESCUE HERE BUT HEAVY LIFTING DONE VALIDATE UTF.
          dh = { row_id: @row_id, valid_encoding: false, encoding_details: er.message, url: nil, act_name: nil, street: nil, city: nil, state: nil, zip: nil, phone: nil }
          @dhs << dh
          binding.pry
          next ## Is next totally needed?  Test without it and see.
        end
      end

      puts @dhs.count
      binding.pry
      ### utf_results will not be sent as large batch.  Will be sent to @dhs in real time.
      # utf_results = compile_results(inval_rows, val_hshs)
      compile_results ## Calls method to handle returns.
    end



    def check_utf(text)
      # result = {text: text, valid_encoding: false, encoding_details: [] }
      # result[:encoding_details] << 'encoded_text'
      # result[:encoding_details] << 'encoded_text'
      # result[:encoding_details] << 'wchar_text'
      # result[:valid_encoding] = false
      # result[:encoding_details] << "#{er.message}"
      # non_utf_texts <<<< !! REPLACED BY was_utfs_need_move:
      # @was_utfs_need_move[:non_utfs] << {row_id: @row_id, non_utf_text: text}
      # @was_utfs_need_move[:non_utfs] << {row_id: @row_id, non_utf_text: text}

      begin
        if !text.valid_encoding?
          text = text.chars.select(&:valid_encoding?).join
          text.gsub!('_', '')
          text = text.delete("^\u{0000}-\u{007F}")
        else
          encoded_text = text.delete("^\u{0000}-\u{007F}")
          if encoded_text != text
            text = encoded_text
          end
        end

        wchar_text = text&.gsub(/\s+/, ' ')&.strip ## Removes carriage returns and new lines.
        if wchar_text != text
          text = wchar_text
        end
      rescue=>e
        puts er.message
        binding.pry
      end

      binding.pry
     text
    end




    ########################################
    ### UTF ENCODING! ###
    #
    # def check_utf(text)
    #   binding.pry
    #   result = {text: text, valid_encoding: false, encoding_details: [] }
    #   # non_utf_texts <<<< !! REPLACED BY was_utfs_need_move:
    #
    #   begin
    #     ### CONSIDER RETURNING HASH FROM HERE, IN check_utf
    #     if !text.valid_encoding?
    #       result[:encoding_details] << 'encoded_text'
    #       @was_utfs_need_move[:non_utfs] << {row_id: @row_id, non_utf_text: text}
    #       text = text.chars.select(&:valid_encoding?).join
    #       text.gsub!('_', '')
    #       text = text.delete("^\u{0000}-\u{007F}")
    #     else
    #       encoded_text = text.delete("^\u{0000}-\u{007F}")
    #       if encoded_text != text
    #         result[:encoding_details] << 'encoded_text'
    #         @was_utfs_need_move[:non_utfs] << {row_id: @row_id, non_utf_text: text}
    #         text = encoded_text
    #       end
    #     end
    #
    #     wchar_text = text&.gsub(/\s+/, ' ')&.strip ## Removes carriage returns and new lines.
    #     if wchar_text != text
    #       result[:encoding_details] << 'wchar_text'
    #       text = wchar_text
    #     end
    #   rescue=>e
    #     ### CONSIDER RETURNING HASH FROM HERE, IN check_utf
    #     puts er.message
    #     result[:valid_encoding] = false
    #     result[:encoding_details] << "#{er.message}"
    #     binding.pry
    #   end
    #
    # binding.pry
    #  text
    # end

    ########## VALIDATE ARRAYS ##########
    def validate_arrays(orig_arrays)
      headers, val_hshs, inval_rows = [], [], []
      ## Not created yet.
      binding.pry
      compile_results ## Calls method to handle returns.
    end


    #########################################################################################################
    ### PROBABLY DON'T NEED BELOW, BUT KEEP SOMEWHERE FOR FUTURE, BECAUSE THEY ARE PRETTY HELPFUL.
    #########################################################################################################
    # def compare_diff(hsh)
    #   binding.pry
    #   ### Need to redo this!
    #
    #   # res = []
    #   # hsh.to_a.reduce do |el, nxt|
    #   #   res << nxt.first if el.last != nxt.last
    #   #   el = nxt
    #   # end
    #   #
    #   # res.compact!
    #   # @was_utfs_need_move += res
    # end
    #########################################################################################################
    ### SAMPLE OF HOW TO CONVERT HASH INTO DOT NOTATION, BUT ONLY IF THERE IS A MODEL.:
    #########################################################################################################
      # # getter
      #     ['row_id', 'type_id', 'status'].each do |key|
      #       define_method key do
      #         dh[key]
      #       end
      #     end
      #
      #
      # # setter
      #     ['row_id', 'type_id', 'status'].each do |key|
      #       define_method key do |val|
      #         dh[key] = val
      #       end
      #     end
      #     # dh.row_id
      #     # dh.row_id = 'gh'
    #########################################################################################################
    ###  CAN RUN BELOW TO GRAB A BUNCH OF NON-UTF8 STRINGS TO TEST check_utf METHOD.
    #########################################################################################################

    # non_utfs = non_utf_strings ## For testing.  Returns array of non-utf8
    def non_utf_strings ## For testing UTF8 Validator
      str_arr = ["𝘀𝔞ｍϱl𝔢", "xC2", "hellÔ!", "hi∑", "hi\x99!", "foo\x92bar"]
      # str_arr += %w(𝘀𝔞ｍϱl𝔢 xC2 hellÔ! hi∑ hi\x99! foo\x92bar)
      str_arr << "2,heritagemazdatowson.com,Heritage Mazda Towson,1630 York Rd_\xED\xBF\x8Cˌ_\xED\xEE\xE4\xF3\xC1\xED_\x8C\xE7_\xED\xBF\x8Cˌ___\xED\xBF\x8Cˌ_\xED\xBF\x8Cˌ__,Lutherville,MD,21093,(877) 361-1038\r\n"

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

      str_arr
    end
    #########################################################################################################
    #########################################################################################################



  end

end
