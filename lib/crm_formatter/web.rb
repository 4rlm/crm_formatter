# frozen_string_literal: false

# require 'rubygems'
# require 'active_support'
require 'csv'

# StartCrm.run_webs
module CrmFormatter
  class Web
    def format_url(url)
      prep_result = prep_for_uri(url)
      url_hash = prep_result[:url_hash]
      url = prep_result[:url]
      url = nil if errors?(url_hash)

      if url&.present?
        url = normalize_url(url)
        ext_result = validate_extension(url_hash, url)
        url_hash = ext_result[:url_hash]
        url = ext_result[:url]
        (url = nil if errors?(url_hash)) if url.present?
      end

      url_hash = consolidate_negs(url_hash)
      url_hash[:url_f] = url
      url_hash = extract_path(url_hash) if url.present?
      url_hash = check_web_status(url_hash)
      url_hash
    end

    ### COMPARE ORIGINAL AND FORMATTED URL ###
    def check_web_status(hsh)
      status = 'invalid' if hsh[:web_neg]&.include?('error')

      if hsh[:url] && hsh[:url_f] && status.nil?
        status = hsh[:url] != hsh[:url_f] ? 'formatted' : 'unchanged'
      end

      hsh[:web_status] = status if status.present?
      hsh
    end

    def consolidate_negs(hsh)
      neg = hsh[:web_neg].join(', ')
      hsh[:web_neg] = neg.present? ? neg : nil
      hsh
    end

    def errors?(url_hash)
      errors = url_hash[:web_neg].map { |web_neg| web_neg.include?('error') }
      errors.any?
    end

    def prep_for_uri(url)
      url_hash = { web_status: nil, url: url, url_f: nil, url_path: nil, web_neg: [] }

      begin
        url = url&.split('|')&.first
        url = url&.split('\\')&.first
        url&.gsub!(/\P{ASCII}/, '')
        url = url&.downcase&.strip

        2.times { remove_ww3(url) } if url.present?
        url = remove_slashes(url) if url.present?
        url&.strip!

        if url.present?
          url = nil if url.include?(' ')
          url = url[0..-2] if url.present? && url[-1] == '/'
        end

        banned_symbols = ['!', '$', '%', "'", '(', ')', '*', '+', ',', '<', '>', '@', '[', ']', '^', '{', '}', '~']
        url = nil if url.present? && banned_symbols.any? { |symb| url&.include?(symb) }
        unless url.present?
          url_hash[:web_neg] << 'error: syntax'
          url_hash[:url_f] = url
        end
      rescue StandardError => error
        url_hash[:web_neg] << "error: #{error}"
        url = nil
        url_hash
      end
      hsh = { url_hash: url_hash, url: url }
      hsh
    end

    def normalize_url(url)
      return unless url.present?
      uri = URI(url)
      scheme = uri&.scheme
      host = uri&.host
      url = "#{scheme}://#{host}" if host.present? && scheme.present?
      url = "http://#{url}" if url[0..3] != 'http'

      return unless url.present?
      url.gsub!('//', '//www.') unless url.include?('www.')
      url
    end

    # Source: http://www.iana.org/domains/root/db
    # Text: http://data.iana.org/TLD/tlds-alpha-by-domain.txt
    def validate_extension(url_hash, url)
      return unless url.present?
      uri_parts = URI(url).host&.split('.')
      url_exts = uri_parts[2..-1]

      ### Finds Errors
      if url_exts.empty? ## Missing ext.
        err_msg = 'error: ext.none'
      else ## Has ext(s), but need to verify validity and count.
        file_path = './lib/crm_formatter/csv/extensions.csv'
        iana_list = CSV.read(file_path).flatten
        matched_exts = iana_list & url_exts

        if matched_exts.empty? ## Has ext, but not valid.
          err_msg = "error: ext.invalid [#{url_exts.join(', ')}]"
        elsif matched_exts.count > 1 ## Has too many valid exts, Limit 1.
          err_msg = "error: ext.valid > 1 [#{matched_exts.join(', ')}]"
        end
      end

      if err_msg
        url_hash[:web_neg] << err_msg
        url = nil
        url_hash[:url_f] = nil
        return { url_hash: url_hash, url: url }
      end

      ### Only Non-Errors Get Here ###
      ## Has one valid ext, but need to check if original url exts were > 1.  Replace if so.
      if url_exts.count > matched_exts.count
        inv_ext = (url_exts - matched_exts).join
        url = url.gsub(".#{inv_ext}", '')
      end

      ext_result = { url_hash: url_hash, url: url }
      ext_result
    end

    ###### Supporting Methods Below #######

    def extract_path(url_hash)
      path_parts = url_hash[:url_f].split('//').last.split('/')[1..-1]
      path = "/#{path_parts.join('/')}"
      if path&.length > 2
        url_hash[:url_path] = path
        url_hash[:url_f] = url_hash[:url_f].gsub(url_hash[:url_path], '')
      end
      url_hash
    end

    # CALL: Wrap.new.remove_ww3(url)
    def remove_ww3(url)
      return unless url.present?
      url.split('.').map { |part| url.gsub!(part, 'www') if part.scan(/ww[0-9]/).any? }
      url&.gsub!('www.www', 'www')
      url
    end

    # For rare cases w/ urls with mistaken double slash twice.
    def remove_slashes(url)
      return url unless url.present? && url.include?('//')
      parts = url.split('//')
      return parts[0..1].join if parts.length > 2
      url
    end

    # def strip_down_url(url)
    #   return unless url.present?
    #   url = url.downcase.strip
    #   url = url.gsub('www.', '')
    #   url = url.split('://')
    #   url[-1]
    # end
  end
end
