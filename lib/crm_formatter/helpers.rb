module CRMFormatter
  module Helpers

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
