require "csv"

module CrmFormatter
  class UTF

    def initialize
      @utf_tls = []
      @non_utf_texts = []
      @row_id = 1
    end

    ## Accepted arg keys & values: either :file_path, :array_of_strings, or :array_of_hashes.
    ## First entry point for UTF, then distributes to 3 diff meth options based on arg name and type.
    def validate_data(arg)
      ## Only accepts 1 arg, even though arg.keys / arg.values being used!
      err_msg = 'Error: Empty args sent to validate_data!'
      return err_msg unless arg&.values&.present?

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

    # CSV.parse(line) do |row|
    #   headers.empty? ? headers = row : val_hshs << row_to_hsh(row, headers)
    # end


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

          val2 = validate_encoding(val)
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

      puts "dif_count: #{dif_count}"
      puts "counter: #{counter}"
      puts "@utf_tls: #{@utf_tls.count}"
      binding.pry

      # utf_results = tally_results(inval_rows, val_hshs)
    end


    ########## VALIDATE CSV ##########
    def validate_csv(file_path)
      headers, val_hshs, inval_rows = [], [], []
      File.open(file_path).each do |line|
        begin
          ######### TEMPORARILY TURNED OFF DURING TESTING!!!
          line = validate_encoding(line)  ######### TEMPORARILY TURNED OFF DURING TESTING!!!
          binding.pry if !line.valid_encoding?

          CSV.parse(line) do |row|
            headers.empty? ? headers = row : val_hshs << row_to_hsh(row, headers)
          end
        rescue => er
          binding.pry
          counter = val_hshs.count + inval_rows.count
          inval_rows << {"#{counter}": "#{er.message}"}
          next
        end
      end

      binding.pry
      utf_results = tally_results(inval_rows, val_hshs)
    end


    ########################################
    ### UTF ENCODING! ###

    def validate_encoding(text)

     if !text.valid_encoding?
       @non_utf_texts << text
       removed_non_utf8 = text.chars.select(&:valid_encoding?).join
       removed_non_utf8.gsub!('_', '')
       removed_non_utf8.gsub!('ˌ', '') ### Keep this for future. If needed.
       removed_non_utf8 = removed_non_utf8.delete("^\u{0000}-\u{007F}")
       removed_carriage_returns = removed_non_utf8&.gsub(/\s+/, ' ')&.strip ## Removes carriage returns and new lines.
       text = removed_carriage_returns  ## removed_non_utf8 is text.
       @non_utf_texts << text
     else
       removed_non_utf8 = text.delete("^\u{0000}-\u{007F}")
       removed_carriage_returns = removed_non_utf8&.gsub(/\s+/, ' ')&.strip ## Removes carriage returns and new lines.

       utf_hsh = { text: text, removed_carriage_returns: removed_carriage_returns, removed_non_utf8: removed_non_utf8 }
       diff = compare_diff(utf_hsh)
       text = removed_carriage_returns
     end

     @row_id +=1
     text
    end
    ########################################


    def compare_diff(hsh)
      res = []
      hsh.to_a.reduce do |el, nxt|
        res << nxt.first if el.last != nxt.last
        el = nxt
      end

      res.compact!
      @utf_tls += res
    end


    def tally_results(inval_rows, val_hshs)
      binding.pry
      ## Need to redo this!!

      # utf_report = { valid: val_hshs.count,
      #   invalid: inval_rows.length,
      #   valid_details: make_groups_from_array(@utf_tls),
      #   invalid_details: inval_rows.each_with_index { |hsh, i| "#{i+1}) Row #{hsh.keys[0]}: #{hsh.values[0]}." }
      # }
      # utf_results = { utf_report: utf_report, valid_csv_hashes: val_hshs }
    end


    def make_groups_from_array(tally_arr)
      ### Need to Redo This!!!

      # hsh_by_grp = tally_arr.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }
      # puts "hsh_by_grp: #{hsh_by_grp}"
      # hsh_by_grp
    end




    ########## VALIDATE ARRAYS ##########
    def validate_arrays(orig_arrays)
      headers, val_hshs, inval_rows = [], [], []
      ## Not created yet.
      binding.pry
    end



    #########################################################################################################
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




  end

end
