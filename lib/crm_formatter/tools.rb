# frozen_string_literal: false

module CrmFormatter
  class Tools

    def letter_case_check(str)
      return unless str.present?
      # str = str.upcase
      str = str.upcase.split(' ')&.each { |el| el.capitalize! if el.gsub(/[^ A-Za-z]/, '')&.strip }&.join(' ')
      str = capitalize_dashes(str)
      str = check_for_brands(str)
      str
    end

    def capitalize_dashes(str)
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

    def check_for_brands(str)
      return unless str.present?
      ['BMW', 'CDJR', 'CJDR', 'GMC', 'CJD'].map do |brand|
        str = str.gsub(brand.capitalize, brand)
      end
      str
    end

  end
end
