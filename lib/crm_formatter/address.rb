# frozen_string_literal: false

module CrmFormatter
  class Address
    def format_full_address(adr={})
      crmf_hash = {
        street_f: format_street(adr[:street]),
        city_f: format_city(adr[:city]),
        state_f: format_state(adr[:state]),
        zip_f: format_zip(adr[:zip])
      }

      crmf_hash[:full_addr_f] = make_full_addr_f(crmf_hash)
      crmf_hash[:address_status] = compare_versions(adr, crmf_hash)
      crmf_hash
    end

    ####### COMPARE ORIGINAL AND FORMATTED ADR ######
    def compare_versions(original, crmf_hash)
      original = make_full_address_original(original)
      crmf = crmf_hash[:full_addr_f]
      original != crmf
    end

    ######### FORMAT FULL ADDRESS ##########
    def make_full_address_original(hsh)
      [hsh[:street], hsh[:city], hsh[:state], hsh[:zip]].compact.join(', ')
    end

    def make_full_addr_f(hsh)
      [hsh[:street_f], hsh[:city_f], hsh[:state_f], hsh[:zip_f]].compact.join(', ')
    end

    ######### FORMAT STREET ##########
    def format_street(street)
      street = street&.gsub(/\s/, ' ')&.strip
      return unless street.present?
      # street = Formatter.new.letter_case_check(street)
      return unless street.present?
      street = CrmFormatter::Tools.new.letter_case_check(street)
      street = " #{street} " # Adds white space, to match below, then strip.
      street&.gsub!('.', ' ')
      street&.gsub!(',', ' ')

      street&.gsub!(' North ', ' N ')
      street&.gsub!(' South ', ' S ')
      street&.gsub!(' East ', ' E ')
      street&.gsub!(' West ', ' W ')
      street&.gsub!(' Ne ', ' NE ')
      street&.gsub!(' Nw ', ' NW ')
      street&.gsub!(' Se ', ' SE ')
      street&.gsub!(' Sw ', ' SW ')

      street&.gsub!('Avenue', 'Ave')
      street&.gsub!('Boulevard', 'Blvd')
      street&.gsub!('Drive', 'Dr')
      street&.gsub!('Expressway', 'Expy')
      street&.gsub!('Freeway', 'Fwy')
      street&.gsub!('Highway', 'Hwy')
      street&.gsub!('Lane', 'Ln')
      street&.gsub!('Parkway', 'Pkwy')
      street&.gsub!('Road', 'Rd')
      street&.gsub!('Route', 'Rte')
      street&.gsub!('Street', 'St')
      street&.gsub!('Terrace', 'Ter')
      street&.gsub!('Trail', 'Trl')
      street&.gsub!('Turnpike', 'Tpke')
      street&.gsub!('|', ' ')
      street&.gsub!('•', ' ')
      street&.gsub!('Welcome to', ' ')
      street&.gsub!('var address = "', ' ')

      street&.strip!
      street&.squeeze!(' ')
      street
    end

    ########## FORMAT CITY ###########

    def format_city(city)
      city = city&.gsub(/\s/, ' ')&.strip
      city = nil if city&.scan(/[0-9]/)&.any?
      city = nil if city&.downcase&.include?('category')
      city = nil if city&.downcase&.include?('model')
      city = nil if city&.downcase&.include?('make')
      city = nil if city&.downcase&.include?('inventory')
      city = nil if city&.downcase&.include?('tracker')
      city = nil if city&.downcase&.include?('push')
      city = nil if city&.downcase&.include?('(')
      city = nil if city&.downcase&.include?(')')
      city = nil if city&.downcase&.include?('[')
      city = nil if city&.downcase&.include?(']')
      city&.gsub!('|', ' ')
      city&.gsub!('•', ' ')

      return unless city.present?
      street_types = %w[avenue boulevard drive expressway freeway highway lane parkway road route street terrace trail turnpike]
      invalid_city = street_types.find { |street_type| city.downcase.include?(street_type) }
      city = nil if invalid_city.present?

      return unless city.present?
      st_types = %w[ave blvd dr expy fwy hwy ln pkwy rd rte st ter trl tpke]
      city_parts = city.split(' ')

      invalid_city = city_parts.select do |city_part|
        st_types.find { |st_type| city_part.downcase == st_type }
      end

      city = nil if invalid_city.present?
      city = nil if city&.downcase&.include?('/')
      city = nil if city&.downcase&.include?('www')
      city = nil if city&.downcase&.include?('*')
      city = nil if city&.downcase&.include?('number')
      city = nil if city&.downcase&.include?('stock')
      city = nil if city&.downcase&.include?(':')
      city = nil if city&.downcase&.include?('ID')

      city&.strip!
      city&.squeeze!(' ')
      city = nil if city.present? && city.length > 50
      city = nil if city.present? && city.length < 4
      city = city&.split(' ')&.map(&:capitalize)&.join(' ')
    end

    ########## FORMAT STATE ##########

    def format_state(state)
      state = state&.gsub(/\s/, ' ')&.strip
      return unless state.present?
      states_hsh = { 'Alabama' => 'AL', 'Alaska' => 'AK', 'Arizona' => 'AZ', 'Arkansas' => 'AR', 'California' => 'CA', 'Colorado' => 'CO', 'Connecticut' => 'CT', 'Delaware' => 'DE', 'Florida' => 'FL', 'Georgia' => 'GA', 'Hawaii' => 'HI', 'Idaho' => 'ID', 'Illinois' => 'IL', 'Indiana' => 'IN', 'Iowa' => 'IA', 'Kansas' => 'KS', 'Kentucky' => 'KY', 'Louisiana' => 'LA', 'Maine' => 'ME', 'Maryland' => 'MD', 'Massachusetts' => 'MA', 'Michigan' => 'MI', 'Minnesota' => 'MN', 'Mississippi' => 'MS', 'Missouri' => 'MO', 'Montana' => 'MT', 'Nebraska' => 'NE', 'Nevada' => 'NV', 'New Hampshire' => 'NH', 'New Jersey' => 'NJ', 'New Mexico' => 'NM', 'New York' => 'NY', 'North Carolina' => 'NC', 'North Dakota' => 'ND', 'Ohio' => 'OH', 'Oklahoma' => 'OK', 'Oregon' => 'OR', 'Pennsylvania' => 'PA', 'Rhode Island' => 'RI', 'South Carolina' => 'SC', 'South Dakota' => 'SD', 'Tennessee' => 'TN', 'Texas' => 'TX', 'Utah' => 'UT', 'Vermont' => 'VT', 'Virginia' => 'VA', 'Washington' => 'WA', 'West Virginia' => 'WV', 'Wisconsin' => 'WI', 'Wyoming' => 'WY' }

      state = state.tr('^A-Za-z', '')
      if state.present? && state.length < 2
        state = nil
      elsif state.present? && state.length > 2
        state = state.capitalize
        states_hsh.map { |k, v| state = v if state == k }
      end

      return unless state.present?
      state.upcase!
      valid_state = states_hsh.find { |_k, v| state == v }
      state_code = valid_state&.last
      state_code
    end

    ########### FORMAT ZIP ###########

    # CALL: Formatter.new.format_zip(zip)
    def format_zip(zip)
      zip = nil unless zip.scan(/[0-9]/).length.in?([4, 5, 8, 9])
      zip = zip&.gsub(/\s/, ' ')&.strip
      zip = zip&.split('-')&.first
      zip = nil if zip&.scan(/[A-Za-z]/)&.any?
      (zip = "0#{zip}" if zip.length == 4) if zip.present?
      (zip = nil if zip.length != 5) if zip.present?
      zip&.strip!
      zip&.squeeze!(' ')
      zip
    end
  end
end
