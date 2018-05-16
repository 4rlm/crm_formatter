scrub_oarequire 'csv'

module CRMFormatter
  class Web

    def initialize(args={})
      @empty_oa = args.empty?
      @pos_urls = args.fetch(:pos_urls, [])
      @neg_urls = args.fetch(:neg_urls, [])
      @pos_links = args.fetch(:pos_links, [])
      @neg_links = args.fetch(:neg_links, [])
      @pos_hrefs = args.fetch(:pos_hrefs, [])
      @neg_hrefs = args.fetch(:neg_hrefs, [])
      @pos_exts = args.fetch(:pos_exts, [])
      @neg_exts = args.fetch(:neg_exts, [])
      @min_length = args.fetch(:min_length, 2)
      @max_length = args.fetch(:max_length, 100)
    end

    def banned_symbols
      banned_symbols = ["!", "$", "%", "'", "(", ")", "*", "+", ",", "<", ">", "@", "[", "]", "^", "{", "}", "~"]
    end

    ##Call: StartCrm.run_webs
    def format_url(url)
      prep_result = prep_for_uri(url)
      url_hash = prep_result[:url_hash]
      url = prep_result[:url]
      url = nil if has_errors(url_hash)

      if url.present?
        uri_result = run_uri(url_hash, url)
        url_hash = uri_result[:url_hash]
        url = uri_result[:url]
        (url = nil if has_errors(url_hash)) if url.present?
      end

      url_hash[:formatted_url] = url
      url_hash = check_reformatted_status(url_hash) if url.present?
      url_hash
    end


    def check_reformatted_status(url_hash)
      formatted = url_hash[:formatted_url]
      if formatted.present?
        url_hash[:is_reformatted] = url_hash[:url_path] != formatted
      end
      url_hash
    end


    def has_errors(url_hash)
      errors = url_hash[:neg].map { |neg| neg.include?('error') }
      errors.any?
    end


    ##Call: StartCrm.run_webs
    def prep_for_uri(url)
      url_hash = { is_reformatted: false, url_path: url, formatted_url: nil, neg: [], pos: [] }
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

        url = nil if url.present? && banned_symbols.any? {|symb| url&.include?(symb) }

        if url.present?
          url_hash = scrub_oa(url_hash, url, 'pos_urls', 'include') if !@empty_oa
          url_hash = scrub_oa(url_hash, url, 'neg_urls', 'include') if !@empty_oa
        else
          url_hash[:neg] << "error: syntax"
          url_hash[:formatted_url] = url
        end

      rescue Exception => e
        url_hash[:neg] << "error: #{e}"
        url = nil
        url_hash
      end

      prep_result = { url_hash: url_hash, url: url }
    end


    ##Call: StartCrm.run_webs
    def run_uri(url_hash, url)
      begin
        uri = URI(url)
        host_parts = uri.host&.split(".")

        url_hash = scrub_oa(url_hash, host_parts, 'pos_exts', 'equal') if !@empty_oa
        url_hash = scrub_oa(url_hash, host_parts, 'neg_exts', 'equal') if !@empty_oa

        host = uri.host
        scheme = uri.scheme
        url = "#{scheme}://#{host}" if host.present? && scheme.present?
        url = "http://#{url}" if url[0..3] != "http"
        url = url.gsub("//", "//www.") if !url.include?("www.")
        samp_url = convert_to_scheme_host(url)

        url = convert_to_scheme_host(url) if url.present?
        url_extens_result = check_url_extens(url_hash, url)
        url_hash = url_extens_result[:url_hash]
        url = url_extens_result[:url]

      rescue Exception => e
        url_hash[:neg] << "error: #{e}"
        url = nil
        url_hash
      end

      uri_result = { url_hash: url_hash, url: url }
    end


    #Source: http://www.iana.org/domains/root/db
    #Text: http://data.iana.org/TLD/tlds-alpha-by-domain.txt
    def check_url_extens(url_hash, url)
      if url.present?
        url_extens = URI(url).host&.split(".")[2..-1]
        if url_extens.count > 1
          file_path = "./lib/crm_formatter/extensions.csv"
          extens_list = CSV.read(file_path).flatten
          valid_url_extens = extens_list & url_extens

          if valid_url_extens.count != 1
            extens_str = valid_url_extens.map { |ext| ".#{ext}" }.join(', ')
            url_hash[:neg] << "error: exts.count > 1 [#{extens_str}]"
            url = nil
          end
        end
      end

      url_hash[:formatted_url] = url
      url_extens_result = {url_hash: url_hash, url: url}
    end


    ## This process, scrub_oa only runs if client OA args were passed at initialization.
    ## Results listed in url_hash[:neg]/[:pos], and don't impact or hinder final formatted url.
    ## Simply adds more details about user's preferences and criteria for the url are.

    def scrub_oa(hash, target, list_name, include_or_equal)
      unless @empty_oa
        if list_name.present?
          criteria_list = instance_variable_get("@#{list_name}")

          if criteria_list.present?
            if target.is_a?(::String)
              tars = target.split(', ')
            else
              tars = target
            end

            pn_matches = tars.map do |tar|
              if criteria_list.present?
                if include_or_equal == 'include'
                  criteria_list.select { |el| el if tar.include?(el) }.join(', ')
                elsif include_or_equal == 'equal'
                  criteria_list.select { |el| el if tar == el }.join(', ')
                end
              end
            end

            pn_match = pn_matches&.uniq&.sort&.join(', ')
            if pn_match.present?
              if list_name.include?('neg')
                hash[:neg] << "#{list_name}: #{pn_match}"
              else
                hash[:pos] << "#{list_name}: #{pn_match}"
              end
            end
          end

        end
      end

      hash
    end

    ###### Supporting Methods Below #######

    def extract_link(url_path)
      url_hash = format_url(url_path)
      url = url_hash[:formatted_url]
      link = url_path
      link_hsh = {url_path: url_path, url: url, link: nil }
      if url.present? && link.present? && link.length > @min_length
        url = strip_down_url(url)
        link = strip_down_url(link)
        link&.gsub!(url, '')
        link = link&.split('.net')&.last
        link = link&.split('.com')&.last
        link = link&.split('.org')&.last
        link = "/#{link.split("/").reject(&:empty?).join("/")}" if link.present?
        link_hsh[:link] = link if link.present? && link.length > @min_length
      end
      link_hsh
    end


    def strip_down_url(url)
      if url.present?
        url = url.downcase.strip
        url = url.gsub('www.', '')
        url = url.split('://')
        url = url[-1]
        return url
      end
    end


    def remove_invalid_links(link)
      link_hsh = {link: link, valid_link: nil, flags: nil }
      if link.present?
        @neg_links += get_symbs
        flags = @neg_links.select { |red| link&.include?(red) }
        flags << "below #{@min_length}" if link.length < @min_length
        flags << "over #{@max_length}" if link.length > @max_length
        flags = flags.flatten.compact
        flags.any? ? valid_link = nil : valid_link = link
        link_hsh[:valid_link] = valid_link
        link_hsh[:flags] = flags.join(', ')
      end
      link_hsh
    end


    def remove_invalid_hrefs(href)
      href_hsh = {href: href, valid_href: nil, flags: nil }
      if href.present?
        @neg_hrefs += get_symbs
        href = href.split('|').join(' ')
        href = href.split('/').join(' ')
        href&.gsub!("(", ' ')
        href&.gsub!(")", ' ')
        href&.gsub!("[", ' ')
        href&.gsub!("]", ' ')
        href&.gsub!(",", ' ')
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
      end
      href_hsh
    end


    def convert_to_scheme_host(url)
      if url.present?
        uri = URI(url)
        scheme = uri&.scheme
        host = uri&.host
        url = "#{scheme}://#{host}" if (scheme.present? && host.present?)
        return url
      end
    end


    #CALL: Formatter.new.remove_ww3(url)
    def remove_ww3(url)
      if url.present?
        url.split('.').map { |part| url.gsub!(part,'www') if part.scan(/ww[0-9]/).any? }
        url&.gsub!("www.www", "www")
      end
    end


    # For rare cases w/ urls with mistaken double slash twice.
    def remove_slashes(url)
      if url.present? && url.include?('//')
        parts = url.split('//')
        return parts[0..1].join if parts.length > 2
      end
      return url
    end

    ##Call: StartCrm.run_webs
    # def get_ext_list
    #   # Source: http://www.iana.org/domains/root/db
    #   # .txt list: http://data.iana.org/TLD/tlds-alpha-by-domain.txt
    #   file_path = "./lib/crm_formatter/extensions.csv"
    #   extensions = CSV.read(file_path)
    # end


  end
end
