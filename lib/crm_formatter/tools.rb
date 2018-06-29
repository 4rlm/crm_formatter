# frozen_string_literal: false

module CrmFormatter
  class Tools

    def letter_case_check(str)
      return unless str.present?
      str = force_capitalize(str)
      str = capitalize_dashes(str)
      str = force_upcase(str)
      str = force_downcase(str)
      str = force_first_cap(str)
      str
    end

    def force_capitalize(str)
      return unless str.present?
      str_parts = str.downcase.split(' ')&.each do |el|
        el.capitalize! if el.gsub(/[^ A-Za-z]/, '')&.strip
      end
      str = str_parts&.join(' ')
    end

    def capitalize_dashes(str)
      return unless str.present?
      if str&.include?('-')
        els = str.split(' ')
        dash_els = els.select { |el| el != '-' && el.include?('-') }

        dash_els.each do |el|
          el_cap = el.split('-').map(&:capitalize).join('-')
          str = str.gsub(el, el_cap)
        end
      end
      str
    end

    def force_upcase(str)
      return unless str.present?
      str = add_space(str)

      grab_ups.map do |up|
        str = str.gsub(" #{up.capitalize} ", " #{up} ")
        str = str.gsub(" #{up.capitalize}-", " #{up}-")
        str = str.gsub("-#{up.capitalize} ", "-#{up} ")
      end
      str = strip_squeeze(str)
    end

    def force_downcase(str)
      return unless str.present?
      str = add_space(str)

      grab_downs.map do |down|
        str = str.gsub(" #{down.capitalize} ", " #{down} ")
      end
      str = strip_squeeze(str)
    end

    def force_first_cap(str)
      str = "#{str[0].upcase}#{str[1..-1]}"
    end

    def add_space(str)
      return unless str.present?
      str = " #{str} "
    end

    def strip_squeeze(str)
      str = str.squeeze(" ")
      str = str.strip
    end

    def grab_downs
      downs = %w[and as both but either for from in just neither nor of only or out so the to whether with yet]
    end

    def grab_ups
      ups = %w[I]
      brands = %w[BMW CDJR CJDR GMC CJD I]
      professional = %w[BA BS MA JD DC PA MD VP SVP EVP CMO CFO CEO]
      states = %w[AK AL AR AZ CA CT DC DE FL GA HI IA ID IL KS KY LA MA MD MI MN MO NC ND NE NH NJ NM NV NY OH OK PA RI SC SD TN TX UT VA VT WA WI WV WY]
      directions = %w[NE NW SE SW]
      ups = [brands, professional, states, directions].flatten.uniq
    end

  end
end
