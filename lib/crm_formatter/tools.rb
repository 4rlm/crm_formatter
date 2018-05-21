module CrmFormatter
  class Tools

    def initialize(args={})
      @args = args
      @empty_args = args.empty?
      @global_hash = %w(row_id url act_name street city zip phone utf_details)
    end

    ## scrub_oa, is only called if client OA args were passed at initialization.
    ## Results listed in url_hash[:neg]/[:pos], and don't impact or hinder final formatted url.
    ## Simply adds more details about user's preferences and criteria for the url are.
    def scrub_oa(hash, target, oa_name, include_or_equal)
      if oa_name.present? && !@empty_args
        criteria = @args.fetch(oa_name.to_sym, [])

        if criteria.any?
          if target.is_a?(::String)
            tars = target.split(', ')
          else
            tars = target
          end

          scrub_matches = tars.map do |tar|
            if criteria.present?
              if include_or_equal == 'include'
                criteria.select { |crit| crit if tar.include?(crit) }.join(', ')
              elsif include_or_equal == 'equal'
                criteria.select { |crit| crit if tar == crit }.join(', ')
              end
            end
          end

          scrub_match = scrub_matches&.uniq&.sort&.join(', ')
          if scrub_match.present?
            if oa_name.include?('neg')
              hash[:neg] << "#{oa_name}: #{scrub_match}"
            else
              hash[:pos] << "#{oa_name}: #{scrub_match}"
            end
          end
        end
      end
      hash
    end


    # @tools.row_to_hsh(keys, row)
    def row_to_hsh(keys, row)
      binding.pry
      # headers = ["url", "act_name", "street", "city", "state", "zip", "phone"]

       # row = ["stanleykaufman.net", "Stanley Chevrolet Kaufman", "8h_l25 E Fair St", "Kaufman", "TX", "75142", "(888) 457-4391"]
      headers = keys.map(&:to_s).join(",")

      h = Hash[headers.zip(row)]
      h.symbolize_keys
    end


    # @tools.update_global_hash(hashes)
    def update_global_hash(hashes)
      global_keys = @global_hash
      keys = hashes.map(&:keys).flatten.uniq.sort
      keys.map!(&:to_s)
      global_keys += keys
      global_keys.uniq!



      row = global_keys.map { |el| nil }
      master = row_to_hsh(global_keys, row)
      binding.pry

      master2 = hashes.map { |hsh| master.update(hsh) }
      binding.pry

      => ["row_id",
 "url",
 "act_name",
 "street",
 "city",
 "zip",
 "phone",
 "utf_details",
 "formatted_url",
 "neg",
 "pos",
 "reformatted",
 "state",
 "url_path"]

 formatted_url => web_url

    end





    #CALL: Formatter.new.letter_case_check(street)
    def self.letter_case_check(str)
      if str.present?
        flashes = str&.gsub(/[^ A-Za-z]/, '')&.strip&.split(' ')
        flash = flashes&.reject {|e| e.length < 3 }.join(' ')

        if flash.present?
          has_caps = flash.scan(/[A-Z]/).any?
          has_lows = flash.scan(/[a-z]/).any?
          if !has_caps || !has_lows
            str = str.split(' ')&.each { |el| el.capitalize! if el.gsub(/[^ A-Za-z]/, '')&.strip&.length > 2 }&.join(' ')
          end
        end
        return str
      end
    end


  end
end
