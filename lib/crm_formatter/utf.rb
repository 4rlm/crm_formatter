require "csv"

module CrmFormatter
  class UTF

    def initialize
      @utf_tls = []
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
      sample_hashes = utf_results[:valid_csv_hashes]
      # binding.pry

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
      # headers, val_hshs, inval_rows = [], [], []

      row_num = 0
      dif_count = 0
      err_rows = []

      new_orig_hashes
      orig_hashes.each do |hsh|

        clean_hsh = hsh.each do |el|
          key = el.first
          val = el.last

          val2 = force_utf_encoding(val)
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
          # line = force_utf_encoding(line)  ######### TEMPORARILY TURNED OFF DURING TESTING!!!
          CSV.parse(line) do |row|
            headers.empty? ? headers = row : val_hshs << row_to_hsh(row, headers)
          end
        rescue => er
          counter = val_hshs.count + inval_rows.count
          inval_rows << {"#{counter}": "#{er.message}"}
          next
        end
      end
      utf_results = tally_results(inval_rows, val_hshs)
    end


    ########################################
    ### UTF ENCODING! ###
    def force_utf_encoding(text)
      carriage_returns = text&.gsub(/\s+/, ' ')&.strip ## Removes carriage returns and new lines.
      non_utf8 = carriage_returns.delete("^\u{0000}-\u{007F}")
      ## Note: carriage_returns & non_utf8 are formatted 'text'.  Just named as such for tallying purposes.
      utf_hsh = { text: text, carriage_returns: carriage_returns, non_utf8: non_utf8 }
      diff = compare_diff(utf_hsh)
      text = non_utf8  ## non_utf8 is text.
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
      utf_report = { valid: val_hshs.count,
        invalid: inval_rows.length,
        valid_details: make_groups_from_array(@utf_tls),
        invalid_details: inval_rows.each_with_index { |hsh, i| "#{i+1}) Row #{hsh.keys[0]}: #{hsh.values[0]}." }
      }
      utf_results = { utf_report: utf_report, valid_csv_hashes: val_hshs }
    end


    def make_groups_from_array(tally_arr)
      hsh_by_grp = tally_arr.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }
      puts "hsh_by_grp: #{hsh_by_grp}"
      hsh_by_grp
    end




    ########## VALIDATE ARRAYS ##########
    def validate_arrays(orig_arrays)
      headers, val_hshs, inval_rows = [], [], []
      ## Not created yet.
      binding.pry
    end




  end

end
