# frozen_string_literal: true

module CrmFormatter
  class Phone
    ## Checks every phone number in table to verify that it meets phone criteria, then calls format_phone method to format Valid results.  Otherwise destroys Invalid phone fields and associations.

    # Call: Formatter.new.validate_phone(phone)
    def validate_phone(phone)
      phone_hsh = { phone: phone, phone_crmf: nil, phone_status: false }
      return phone_hsh unless phone.present?
      phone = phone&.gsub(/\s/, ' ')&.strip
      reg = Regexp.new('[(]?[0-9]{3}[ ]?[)-.]?[ ]?[0-9]{3}[ ]?[-. ][ ]?[0-9]{4}')
      return phone_hsh if phone.first == '0' || phone.include?('(0') || !reg.match(phone)
      phone_hsh[:phone_crmf] = format_phone(phone)
      phone_hsh[:phone_status] = phone_hsh[:phone] != phone_hsh[:phone_crmf]
      phone_hsh
    end

    #################################
    ## FORMATS PHONE AS: (000) 000-0000
    ## Assumes phone is legitimate, then formats.  Not designed to detect Valid phone number.

    # Call: Formatter.new.format_phone(phone)
    def format_phone(phone)
      regex = Regexp.new('[A-Z]+[a-z]+')
      if !phone.blank? && (phone != 'N/A' || phone != '0') && !regex.match(phone)
        phone_stripped = phone.gsub(/[^0-9]/, '')
        phone_step2 = phone_stripped && phone_stripped[0] == '1' ? phone_stripped[1..-1] : phone_stripped
        final_phone = !(phone_step2 && phone_step2.length < 10) ? "(#{phone_step2[0..2]}) #{(phone_step2[3..5])}-#{(phone_step2[6..9])}" : phone
      else
        final_phone = nil
      end
      final_phone
    end
  end
end
