require "csv"

module CrmFormatter
  class UTF

    ## Accepted arg keys & values: either :file_path, :array_of_strings, or :array_of_hashes.
    def validate_data(arg)
      ## Only accepts 1 arg, even though arg.keys / arg.values being used!
      err_msg = 'Error: Empty args sent to validate_data!'
      return err_msg unless arg&.values&.present?

      arg_key = arg.keys.first
      arg_val = arg.values.first

      binding.pry
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
      counter = 0
      inval_rows = []
      val_hshs = []
      headers = []
      rows = []

      File.open(file_path).each do |line|
        begin
          # line_1 = line&.gsub(/\s/, ' ')&.strip ## Removes carriage returns and new lines.
          # line_2 = force_utf_encoding(line_1) ## Removes non-utf chars.
          line = force_utf_encoding(line)

          CSV.parse(line) do |row|
            row = row.collect { |x| x.try(:strip) } ## Strips white space from each el in row array.
            if counter > 0
              val_hshs << row_to_hsh(row, headers)
              rows << row
            else
              headers = row
            end
            counter += 1
          end
        rescue => er
          inval_rows << {"#{counter}": "#{er.message}"}
          counter += 1
          next
        end
      end
      utf_results = tally_results(inval_rows, val_hshs)
      # utf_results = { error_report: tally_results(inval_rows, val_hshs), valid_csv_hashes: val_hshs }
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

    # def row_to_hsh(row)
    #   h = Hash[@headers.zip(row)]
    #   h.symbolize_keys
    # end

    def val_hsh(cols, hsh)
      keys = hsh.keys
      keys.each { |key| hsh.delete(key) if !cols.include?(key) }
      hsh
    end


    def force_utf_encoding(text)
      text = text&.gsub(/\s/, ' ')&.strip ## Removes carriage returns and new lines.
      clean_text = text.delete("^\u{0000}-\u{007F}")
      clean_text = clean_text.gsub(/\s+/, ' ')
      clean_text
    end


    def validate_arrays(orig_arrays)
      ## Not created yet.
      binding.pry
    end


    def validate_hashes(orig_hashes)
      counter = 0
      inval_rows = []
      val_hshs = []
      headers = []
      rows = []

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
