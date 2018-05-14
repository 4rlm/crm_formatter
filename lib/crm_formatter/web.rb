module CRMFormatter
  class Web

      def initialize(args={})
        @url_flags = args.fetch(:url_flags, [])
        @link_flags = args.fetch(:link_flags, [])
        @href_flags = args.fetch(:href_flags, [])
        @extension_flags = args.fetch(:extension_flags, [])
        @length_min = args.fetch(:length_min, 2)
        @length_max = args.fetch(:length_max, 100)
      end

      def format_url(url)
        url_hsh = {url_path: url, formatted_url: nil, url_edit: false }
        if url.present?
          begin
            url = url&.split('|')&.first
            url = url&.split('\\')&.first
            url&.gsub!(/\P{ASCII}/, '')
            url = url&.downcase&.strip
            return url_hsh if url&.length < @length_min

            2.times { remove_ww3(url) } if url.present?
            url = remove_slashes(url) if url.present?
            url&.strip!

            return url_hsh if !url.present? || url&.include?(' ')
            url = url[0..-2] if url[-1] == '/'

            symbs = ['(', ')', '[', ']', '{', '}', '*', '@', '^', '$', '+', '!', '<', '>', '~', ',', "'"]

            return url_hsh if symbs.any? {|symb| url&.include?(symb) }

            uri = URI(url)
            if uri.present?
              host_parts = uri.host&.split(".")

              if @extension_flags.any?
                bad_host_sts = host_parts&.map { |part| TRUE if @extension_flags.any? {|ext| part == ext } }&.compact&.first
                return url_hsh if bad_host_sts
              end

              host = uri.host
              scheme = uri.scheme
              url = "#{scheme}://#{host}" if host.present? && scheme.present?
              url = "http://#{url}" if url[0..3] != "http"
              url = url.gsub("//", "//www.") if !url.include?("www.")

              return url_hsh if @url_flags.any? { |bad_text| url&.include?(bad_text) }

              url_hsh[:formatted_url] = convert_to_scheme_host(url) if url.present?
              url_hsh[:url_edit] = url_hsh[:formatted_url] != url_hsh[:url_path]
            end
          rescue
            return url_hsh
          end
        end
        url_hsh
      end


      ###### Supporting Methods Below #######

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


      def extract_link(url_path)
        url_hsh = format_url(url_path)
        url = url_hsh[:formatted_url]
        link = url_path
        link_hsh = {url_path: url_path, url: url, link: nil }
        if url.present? && link.present? && link.length > @length_min
          url = strip_down_url(url)
          link = strip_down_url(link)
          link&.gsub!(url, '')
          link = link&.split('.net')&.last
          link = link&.split('.com')&.last
          link = link&.split('.org')&.last
          link = "/#{link.split("/").reject(&:empty?).join("/")}" if link.present?
          link_hsh[:link] = link if link.present? && link.length > @length_min
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
          invalid_chars = ['(', ')', '[', ']', '{', '}', '*', '@', '^', '$', '%', '+', '!', '<', '>', '~', ',', "'"]
          @link_flags += invalid_chars
          flags = @link_flags.select { |red| link&.include?(red) }
          flags << "below #{@length_min}" if link.length < @length_min
          flags << "over #{@length_max}" if link.length > @length_max
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
          symbs = ['{', '}', '*', '@', '^', '$', '%', '+', '!', '<', '>', '~']
          @href_flags += symbs
          href = href.split('|').join(' ')
          href = href.split('/').join(' ')
          href&.gsub!("(", ' ')
          href&.gsub!(")", ' ')
          href&.gsub!("[", ' ')
          href&.gsub!("]", ' ')
          href&.gsub!(",", ' ')
          href&.gsub!("'", ' ')

          flags = []
          flags << "over #{@length_max}" if href.length > @length_max
          invalid_text = Regexp.new(/[0-9]/)
          flags << invalid_text&.match(href)
          href = href&.downcase
          href = href&.strip

          flags << @href_flags.select { |red| href&.include?(red) }
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

  end
end
