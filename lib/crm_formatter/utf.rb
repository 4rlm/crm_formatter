# frozen_string_literal: true
# require 'csv'

module CrmFormatter
  class UTF
    def initialize(args={})
      @utf_result = { stats: {}, data: {} }
      @valid_rows = []
      @encoded_rows = []
      @defective_rows = []
      @error_rows = []
      @headers = []
      @row_id = 0
      @data_hash = {}
    end

    #################### * VALIDATE DATA * ####################
    def validate_data(args={})
      @seed = Seed.new if args.fetch(:pollute_seeds)

      file_path = args[:file_path]
      data = args[:data]

      utf_result = validate_csv(file_path) if file_path
      utf_result = validate_hashes(data) if data
      utf_result
    end

    #################### * COMPILE RESULTS * ####################
    def compile_results
      utf_status = @valid_rows.map { |hsh| hsh[:utf_status] }
      mapped_details = utf_status.map { |str| str.split(', ') }.flatten.compact
      groups = make_groups_from_array(mapped_details)
      wchar = groups['wchar']
      perfect = groups['perfect']

      header_row_count = @headers.any? ? 1 : 0
      stats = { total_rows: @row_id, header_row: header_row_count, valid_rows: @valid_rows.count, error_rows: @error_rows.count, defective_rows: @defective_rows.count, perfect_rows: perfect, encoded_rows: @encoded_rows.count, wchar_rows: wchar }
      data = { valid_data: @valid_rows, encoded_data: @encoded_rows, defective_data: @defective_rows, error_data: @error_rows }
      @utf_result = { stats: stats, data: data }
      utf_result = @utf_result
      initialize
      utf_result
    end

    #################### * VALIDATE CSV * ####################
    def validate_csv(file_path)
      return unless file_path.present?
      File.open(file_path).each do |file_line|
        validated_line = utf_filter(check_utf(file_line))
        @row_id += 1
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
      rescue StandardError => error
        @error_rows << { row_id: @row_id, text: error.message }
      end
      compile_results
    end

    #################### * VALIDATE HASHES * ####################
    def validate_hashes(orig_hashes)
      return unless orig_hashes.present?
      begin
        process_hash_row(orig_hashes.first) ## re keys for headers.
        orig_hashes.each { |hsh| process_hash_row(hsh) } ## re values
      rescue StandardError => error
        @error_rows << { row_id: @row_id, text: error.message }
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

      file_line = keys_or_values.join(',')
      line_parse(utf_filter(check_utf(file_line)))
    end

    ### line_parse - helper VALIDATE HASHES ###
    ### Parses line to row, then updates final results.
    def line_parse(validated_line)
      return unless validated_line
      row = validated_line.split(',')
      return unless row.any?
      if @headers.empty?
        @headers = row
      else
        @data_hash.merge!(row_to_hsh(row))
        @valid_rows << @data_hash
      end
    end

    #################### * CHECK UTF * ####################
    def check_utf(text)
      return unless text.present?
      text = @seed.pollute_seeds(text) if @seed && @headers.any?
      results = { text: text, encoded: nil, wchar: nil, error: nil }
      begin
        if !text.valid_encoding?
          encoded = text.chars.select(&:valid_encoding?).join
          encoded.delete!('_')
          encoded = encoded.delete("^\u{0000}-\u{007F}")
        else
          encoded = text.delete("^\u{0000}-\u{007F}")
        end
        wchar = encoded&.gsub(/\s+/, ' ')&.strip
        results[:encoded] = encoded if text != encoded
        results[:wchar] = wchar if encoded != wchar
      rescue StandardError => error
        results[:error] = error.message if error
      end
      results
    end

    #################### * UTF FILTER * ####################
    def utf_filter(utf)
      return unless utf.present?
      puts utf.inspect
      utf_status = utf.except(:text).compact.keys
      utf_status = utf_status&.map(&:to_s)&.join(', ')
      utf_status = 'perfect' if utf_status.blank?

      encoded = utf[:text] if utf[:encoded]
      error = utf[:error]
      line = utf.except(:error).compact.values.last unless error
      data_hash = { row_id: @row_id, utf_status: utf_status }

      @encoded_rows << { row_id: @row_id, text: encoded } if encoded
      @error_rows << { row_id: @row_id, text: error } if error
      @defective_rows << filt_utf_hsh[:text] if error
      @data_hash = data_hash if @data_hash[:row_id] != @row_id
      line
    end

    ############# !! HELPERS BELOW !! #############
    ############# KEY VALUE CONVERTERS #############
    def row_to_hsh(row)
      h = Hash[@headers.zip(row)]
      h.symbolize_keys
    end

    def val_hsh(cols, hsh)
      keys = hsh.keys
      keys.each { |key| hsh.delete(key) unless cols.include?(key) }
      hsh
    end

    def make_groups_from_array(array)
      array.each_with_object(Hash.new(0)) { |e, h| h[e] += 1; }
    end

  end
end
