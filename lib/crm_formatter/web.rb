# frozen_string_literal: false

# require 'rubygems'
# require 'active_support'
require 'csv'

# StartCrm.run_webs
module CrmFormatter
  class Web
    def initialize(args={})
      # Args get passed to tools for scrubbing list.
      # Args List: pos_urls, neg_urls, pos_links, neg_links, pos_hrefs, neg_hrefs, pos_exts, neg_exts
      @tools = CrmFormatter::Tools.new(args={})
      @empty_args = args.blank?
      @min_length = args.fetch(:min_length, 2)
      @max_length = args.fetch(:max_length, 100)
    end

    def banned_symbols
      ['!', '$', '%', "'", '(', ')', '*', '+', ',', '<', '>', '@', '[', ']', '^', '{', '}', '~']
    end

    # StartCrm.run_webs
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

      url_hash = consolidate_neg_pos(url_hash)
      url_hash[:url_f] = url
      # url_hash = check_web_status(url_hash) if url.present?
      url_hash = check_web_status(url_hash)
      url_hash
    end

    ####### COMPARE ORIGINAL AND FORMATTED URL ######
    def check_web_status(hsh)
      url_path = hsh[:url_path]
      url_f = hsh[:url_f]
      hsh[:web_neg].include?('error') ? status = 'error' : status = nil

      if url_path && url_f && status.nil?
        url_path != url_f ? status = 'formatted' : status = 'unchanged'
      end

      hsh[:web_status] = status
      hsh
    end

    def consolidate_neg_pos(hsh)
      neg = hsh[:web_neg].join(', ')
      pos = hsh[:web_pos].join(', ')
      neg.present? ? hsh[:web_neg] = neg : hsh[:web_neg] = nil
      pos.present? ? hsh[:web_pos] = pos : hsh[:web_pos] = nil
      hsh
    end

    def errors?(url_hash)
      errors = url_hash[:web_neg].map { |web_neg| web_neg.include?('error') }
      errors.any?
    end

    # StartCrm.run_webs
    def prep_for_uri(url)
      url_hash = { web_status: false, url_path: url, url_f: nil, web_neg: [], web_pos: [] }
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
      { url_hash: url_hash, url: url }
    end

    def normalize_url(url)
      return unless url.present?
      uri = URI(url)
      scheme = uri&.scheme
      host = uri&.host
      url = "#{scheme}://#{host}" if host.present? && scheme.present?
      url = "http://#{url}" if url[0..3] != 'http'
      return url.gsub('//', '//www.') unless url.include?('www.')
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

      return { url_hash: url_hash, url: url } if @empty_args
      run_scrub(url_hash, url, matched_exts)
    end

    def run_scrub(url_hash, url, matched_exts)
      url_hash = @tools.scrub_oa(url_hash, matched_exts, 'pos_exts', 'equal')
      url_hash = @tools.scrub_oa(url_hash, matched_exts, 'neg_exts', 'equal')
      url_hash = @tools.scrub_oa(url_hash, url, 'pos_urls', 'include')
      url_hash = @tools.scrub_oa(url_hash, url, 'neg_urls', 'include')
      { url_hash: url_hash, url: url }
    end

    ###### Supporting Methods Below #######

    def extract_link(url_path)
      url_hash = format_url(url_path)
      url = url_hash[:url_f]
      link = url_path
      link_hsh = { url_path: url_path, url: url, link: nil }
      return link_hsh unless url.present? && link.present? && link.length > @min_length
      url = strip_down_url(url)
      link = strip_down_url(link)
      link&.gsub!(url, '')
      link = link&.split('.net')&.last
      link = link&.split('.com')&.last
      link = link&.split('.org')&.last
      link = "/#{link.split('/').reject(&:empty?).join('/')}" if link.present?
      link_hsh[:link] = link if link.present? && link.length > @min_length
      link_hsh
    end

    def strip_down_url(url)
      return unless url.present?
      url = url.downcase.strip
      url = url.gsub('www.', '')
      url = url.split('://')
      url[-1]
    end

    def remove_invalid_links(link)
      link_hsh = { link: link, valid_link: nil, flags: nil }
      return link_hsh unless link.present?
      @neg_links += get_symbs
      flags = @neg_links.select { |red| link&.include?(red) }
      flags << "below #{@min_length}" if link.length < @min_length
      flags << "over #{@max_length}" if link.length > @max_length
      flags = flags.flatten.compact
      valid_link = flags.any? ? nil : link
      link_hsh[:valid_link] = valid_link
      link_hsh[:flags] = flags.join(', ')
      link_hsh
    end

    def remove_invalid_hrefs(href)
      href_hsh = { href: href, valid_href: nil, flags: nil }
      return href_hsh unless href.present?
      @neg_hrefs += get_symbs
      href = href.split('|').join(' ')
      href = href.split('/').join(' ')
      href&.gsub!('(', ' ')
      href&.gsub!(')', ' ')
      href&.gsub!('[', ' ')
      href&.gsub!(']', ' ')
      href&.gsub!(',', ' ')
      href&.gsub!("'", ' ')

      flags = []
      flags << "over #{@max_length}" if href.length > @max_length
      invalid_text = Regexp.new(/[0-9]/)
      flags << invalid_text&.match(href)
      href = href&.downcase
      href = href&.strip

      flags << @neg_hrefs.select { |red| href&.include?(red) }
      flags = flags.flatten.compact.uniq
      href_hsh[:valid_href] = href unless flags.any?
      href_hsh[:flags] = flags.join(', ')
      href_hsh
    end

    # CALL: Formatter.new.remove_ww3(url)
    def remove_ww3(url)
      return unless url.present?
      url.split('.').map { |part| url.gsub!(part, 'www') if part.scan(/ww[0-9]/).any? }
      url&.gsub!('www.www', 'www')
    end

    # For rare cases w/ urls with mistaken double slash twice.
    def remove_slashes(url)
      return url unless url.present? && url.include?('//')
      parts = url.split('//')
      return parts[0..1].join if parts.length > 2
      url
    end
  end
end
