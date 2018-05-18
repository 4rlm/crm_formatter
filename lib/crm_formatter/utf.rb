require "csv"

module CrmFormatter
  class UTF

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

      binding.pry
      utf_results
    end



    def validate_csv(file_path)
      headers, val_hshs, inval_rows = [], [], []
      File.open(file_path).each do |line|
        begin
          line = force_utf_encoding(line)
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

    def tally_results(inval_rows, val_hshs)
      error_report = { valid_count: val_hshs.count, invalid_count: inval_rows.length,
        error_details: inval_rows.each_with_index { |hsh, i| "#{i+1}) Row #{hsh.keys[0]}: #{hsh.values[0]}." } }
      utf_results = { error_report: error_report, valid_csv_hashes: val_hshs }
    end

    def row_to_hsh(row, headers)
      h = Hash[headers.zip(row)]
      h.symbolize_keys
    end

    def val_hsh(cols, hsh)
      keys = hsh.keys
      keys.each { |key| hsh.delete(key) if !cols.include?(key) }
      hsh
    end


    ########################################
    ### UTF ENCODING! ###
    def force_utf_encoding(text)
      text = text&.gsub(/\s/, ' ')&.strip ## Removes carriage returns and new lines.
      clean_text = text.delete("^\u{0000}-\u{007F}")
      clean_text = clean_text.gsub(/\s+/, ' ')
      clean_text.squeeze!(" ")
      clean_text.strip!
      clean_text
    end






    def validate_arrays(orig_arrays)
      headers, val_hshs, inval_rows = [], [], []
      ## Not created yet.
      binding.pry
    end


    def validate_hashes(orig_hashes)
      headers, val_hshs, inval_rows = [], [], []

      binding.pry
      orig_hashes.map do |hsh|
        binding.pry

        if hsh.values.present?
          result_hash = hsh.map { |k,v| force_utf_encoding(text) }

        end


      end
      binding.pry

      utf_results = tally_results(inval_rows, val_hshs)
      utf_results
    end



  end

end
