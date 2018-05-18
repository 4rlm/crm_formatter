require "csv"

module CrmFormatter
  class Parser

    def parse_csv
      counter = 0
      invalid_row_nums = []
      valid_hashes = []
      @headers = []
      @rows = []
      file_path = "./lib/crm_formatter/seeds.csv"
      binding.pry

      File.open(file_path).each do |line|
        begin
          line_1 = line&.gsub(/\s/, ' ')&.strip ## Removes carriage returns and new lines.
          line_2 = force_utf_encoding(line_1) ## Removes non-utf8 chars.

          CSV.parse(line_2) do |row|
            row = row.collect { |x| x.try(:strip) } ## Strips white space from each el in row array.

            if counter > 0
              valid_hashes << row_to_hsh(row)
              @rows << row
            else
              @headers = row
            end

            counter += 1
          end
        rescue => er
          invalid_row_nums << {"#{counter}": "#{er.message}"}
          counter += 1
          next
        end
      end
      parsed_results = { error_report: tally_results(invalid_row_nums, valid_hashes), valid_csv_hashes: valid_hashes }
    end

    def tally_results(invalid_row_nums, valid_hashes)
      error_report = { valid_row_count: valid_hashes.count, invalid_row_count: invalid_row_nums.length,
        error_details: invalid_row_nums.each_with_index { |hsh, i| puts "#{i+1}) Row #{hsh.keys[0]}: #{hsh.values[0]}." } }
    end

    def row_to_hsh(row)
      h = Hash[@headers.zip(row)]
      h.symbolize_keys
    end

    def val_hsh(cols, hsh)
      keys = hsh.keys
      keys.each { |key| hsh.delete(key) if !cols.include?(key) }
      hsh
    end

    def force_utf_encoding(text)
      # text = "Ã¥ÃŠÃ¥Â©team auto solutions"
      # text = "Ã¥ÃŠÃ¥ÃŠÃ¥ÃŠour staff"
      clean_text = text.delete("^\u{0000}-\u{007F}")
      clean_text = clean_text.gsub(/\s+/, ' ')
    end

  end

end
