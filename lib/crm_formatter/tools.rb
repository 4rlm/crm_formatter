module CRMFormatter
  class Tools

    ## scrub_oa, is only called if client OA args were passed at initialization.
    ## Results listed in url_hash[:neg]/[:pos], and don't impact or hinder final formatted url.
    ## Simply adds more details about user's preferences and criteria for the url are.
    def scrub_oa(hash, target, oa_name, include_or_equal)
      if oa_name.present? && !SHARED_ARGS.empty?
        criteria = SHARED_ARGS[oa_name.to_sym]

        if criteria.present?
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
