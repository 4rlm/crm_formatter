# frozen_string_literal: false

module CrmFormatter
  class Proper
    def format_proper(string)
      str_hsh = { proper_status: nil, proper: string, proper_f: nil }
      return str_hsh unless string.present?
      str_hsh[:proper_f] = CrmFormatter::Tools.new.letter_case_check(string)
      str_hsh = check_proper_status(str_hsh)
    end

    ####### COMPARE ORIGINAL AND FORMATTED PROPER ######
    def check_proper_status(hsh)
      proper = hsh[:proper]
      proper_f = hsh[:proper_f]
      status = 'invalid'
      status = proper != proper_f ? 'formatted' : 'unchanged' if proper && proper_f
      hsh[:proper_status] = status if status.present?
      hsh
    end
  end
end
