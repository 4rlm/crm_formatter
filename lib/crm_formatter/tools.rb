module CrmFormatter
  class Tools

    def initialize(args={})
      @args = args
      @empty_args = args.empty?
      @global_hash = {:row_id=>nil, :act_name=>nil, :street=>nil, :city=>nil, :state=>nil, :zip=>nil, :phone=>nil, :url=>nil, :url_f=>nil, :url_path=>nil, :web_status=>nil, :web_neg=>nil, :web_pos=>nil, :utf_status=>nil}
    end

    # @tools.get_global_hash
    def get_global_hash
      keys = "row_id, act_name, street, city, state, zip, phone, url, url_f, url_path, web_status, web_neg, web_pos, utf_status"
      headers = keys.split(', ')
      headers = headers.map(&:to_sym)
      row = headers.map { |el| nil }
      @global_hash = row_to_hsh(headers, row)
    end


    # @tools.update_global_hash(local_keys)
    def update_global_hash(local_keys)
      gkeys = @global_hash.keys
      local_keys
      lkeys = lkeys.uniq.sort
      # lkeys = lkeys.map(&:to_sym)
      # gkeys = gkeys.map(&:to_sym)
      add_to_global = lkeys - gkeys
      same_keys = lkeys && gkeys
      add_to_global += same_keys - gkeys
      add_to_global&.uniq!

      if add_to_global.any?
        add_to_global += gkeys
        row = add_to_global.map { |el| nil }
        @global_hash = row_to_hsh(global_keys, row)
      end
    end


    # @tools.row_to_hsh(headers, row)
    def row_to_hsh(headers, row)
      headers = headers.map(&:to_sym)
      hash = Hash[headers.zip(row)]
    end



    ## scrub_oa, is only called if client OA args were passed at initialization.
    ## Results listed in url_hash[:web_neg]/[:web_pos], and don't impact or hinder final formatted url.
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
            if oa_name.include?('web_neg')
              hash[:web_neg] << "#{oa_name}: #{scrub_match}"
            else
              hash[:web_pos] << "#{oa_name}: #{scrub_match}"
            end
          end
        end
      else
      end
      hash
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
