# CRMFormatter

Reformat and Normalize CRM Contact Data, Addresses, Phones, Emails and URLs.  
Please note, that this gem is a rapid work in process.  It is from a collection of modules currently being used on a production app, but decided to open them up.  The tests have not yet been written for the gem and there will still be changes in the near future.  Documentation is limited, but is coming.  Here are some basic points below to help you get started.

## Getting Started

In your Gemfile add:

```
gem 'crm_formatter', '~> 1.0.6.pre.rc.1'
```

Or to install locally:

```
gem install crm_formatter --pre
```

### Prerequisites

CRMFormatter is optimized for Rails 5.2 and Ruby 2.5, but has worked well in older versions too.

### Architecture

CRMFormatter is the top level Module wrapper comprising of 3 Classes, Address, Phone and Web.  There is also a Helpers Module for shared tasks.


### Usage

CRMFormatter could be used anywhere in an app for various reasons.  Most commonly from an app's helper methods, controllers or model.  If you wanted to ensure all new data is properly formatted before saving, methods could be accessed from the model via before_save, callbacks, or validations.  In addition to CRMFormatter formatting CRM data, it also provides detailed reports on what if anything has changed and it always preserves the original data submitted.  Here are a few examples below of how it could be used.

The gem can be used both en mass to clean up an entire database, or fully-integrated into an app's regular environment.
They were however, designed for an app that Harvests business data for sales and marketing teams, so they work perfectly with NokoGiri and Mechanize!

** These are just examples below, not strict usage guides ...

### Usage by Class & Methods
* The examples at the bottom of the page are rather verbose, so first, here is a list of methods available to you.

# Address

* 'get_full_address' takes a hash of address parts then runs each through their respective formatters, then also adds an additional feature of combining them into a long full address string, and indicates if there were any changes from the original version and newly formatted.

```
  addr_formatter = CRMFormatter::Address.new

  full_address_hsh = {street: street, city: city, state: state, zip: zip}
  
  addr_formatter.get_full_address(full_address_hsh)

  addr_formatter.format_street(street)

  addr_formatter.format_city(city)

  addr_formatter.format_state(state)

  addr_formatter.format_zip(zip)

  addr_formatter.format_full_address(adr = {})

  addr_formatter.compare_versions(original, formatted)


```

# Phone

* Subtle but important distinction between 'format_phone' which simply puts a phone in any format, like 555-123-4567 into normalized (555) 123-4567, and 'validate_phone' which also uses 'format_phone' to normalize its output, but is mainly tasked with determining if the phone number seem legitimate. If you know for sure that it is a phone number, but just want to normalize then first try format_phone.  If you are doing web scraping or throwing in strings of text mixed with phones, then validate_phone might work better.

```
  ph_formatter = CRMFormatter::Phone.new

  ph_formatter.validate_phone(phone)

  ph_formatter.format_phone(phone)

```

# Web



```
  web_formatter = CRMFormatter::Web.new

  web_formatter.format_url(url)

  web_formatter.extract_link(url_path)

  web_formatter.remove_invalid_links(link)

  web_formatter.remove_invalid_hrefs(href)

  web_formatter.convert_to_scheme_host(url)

```










* Data will always be returned as hashes, with your original, modified, and details about what has changed.
* You may pass optional arguments at initialization to provide lists of data to match against, for example a list of words that if in a URL, it would automatically report as junk (but still keeping your original in tact.)

Typically, you will want to create your own method as a wrapper for the Gem methods, like below...

## Address
** The examples below are rather verbose, so you can make them much more compact of course.

```
def self.run_adrs

  crm_address_formatter = CRMFormatter::Address.new

  contacts = Contact.where.not(full_address: nil)

  contacts.each do |contact|

    cont_adr_hsh = { street: contact.street, city: contact.city,
                    state: contact.state, zip: contact.zip }

    formatted_address_hsh = crm_address_formatter.format_full_address(cont_adr_hsh)

  end

end

```



## Phone

In the phone example, format_all_phone_in_my_db could be a custom wrapper method, which when called by Rails C or from a front end GUI process, could grab all phones in db meeting certain criteria to be scrubbed. The results will always be in hash format, such as below.... phone_hash  

```
@crm_phone = CRMFormatter::Phone.new

def self.format_all_phone_in_my_db
  phones_from_contacts = Contacts.where.not(phone: nil)

  phones_from_contacts.each do |contact|
    phone_hash = @crm_phone.validate_phone(contact.phone)  
  end

end

phone_hash = { phone: 555-123-4567, valid_phone: (555) 123-4567, phone_edit: true }
```


## Web

In the example below, you might write a wrapper method named anything you like, such as 'format_a_url' and 'clean_many_websites' to pass in urls to be formatted.

```
  @web = CRMFormatter::Web.new

  def format_a_url(url)
    hsh = @web.format_url(url)
  end

  def clean_many_websites(array_of_urls)

    hashes = array_of_urls.map do |url|
                @web.format_url(url)
              end

  end
```


### Additional Usage Examples

### Webs
* Another example below.

```
def self.run_webs

  url_flags = %w(approv avis budget business collis eat enterprise facebook financ food google gourmet hertz hotel hyatt insur invest loan lube mobility motel motorola parts quick rent repair restaur rv ryder service softwar travel twitter webhost yellowpages yelp youtube)

  link_flags = %w(: .biz .co .edu .gov .jpg .net // anounc book business buy bye call cash cheap click collis cont distrib download drop event face feature feed financ find fleet form gas generat graphic hello home hospi hour hours http info insta)

  href_flags = %w(? .com .jpg @ * after anounc apply approved blog book business buy call care career cash charit cheap check click)

  extension_flags = %w(au ca edu es gov in ru uk us)

  args = { url_flags: url_flags, link_flags: link_flags, href_flags: href_flags, extension_flags: extension_flags }
  web = CRMFormatter::Web.new(args)

  urls = Accounts.where.not(url: nil).pluck(:url)

  validated_url_hashes = urls.map { |url| web.format_url(url) }
  valid_urls = validated_url_hashes.map { |hsh| hsh[:valid_url] }.compact
  extracted_link_hashes = urls.map { |url| web.extract_link(url) }
  links = extracted_link_hashes.map { |hsh| hsh[:link] }.compact
  validated_link_hashes = links.map { |link| web.remove_invalid_links(link) }
  hrefs = ["Hot Inventory", "Join Our Sale!", "Don't Wait till Later", "Apply Today!", "No Cash Down!"]
  validated_href_hashes = hrefs.map { |href| web.remove_invalid_hrefs(href) }

end

```

### Fully Integrated into an App Example
** The gem is currently being used within another app in the following way...

```
  @web_formatter.convert_to_scheme_host(url)
  @web_formatter.format_url(url)
```
 The two methods above, which are many available to you in the gem are being used below.
```
  curl_result[:response_code] = result&.response_code.to_s
  web_hsh = @web_formatter.format_url(result&.last_effective_url)

  if web_hsh[:formatted_url].present?
    curl_result[:verified_url] = @web_formatter.convert_to_scheme_host(web_hsh[:formatted_url])
  end

```

# Above is an isolated sliver of the larger environment shown below...

```
  def start_curl(url, timeout)

    curl_result = { verified_url: nil, response_code: nil, curl_err: nil }
    if url.present?
      result = nil

      begin # Curl Exception Handling
        begin # Timeout Exception Handling
          Timeout.timeout(timeout) do
            puts "\n\n=== WAITING FOR CURL RESPONSE ==="
            result = Curl::Easy.perform(url) do |curl|
              curl.follow_location = true
              curl.useragent = "curb"
              curl.connect_timeout = timeout
              curl.enable_cookies = true
              curl.head = true #testing - new
            end # result

            curl_result[:response_code] = result&.response_code.to_s
            web_hsh = @web_formatter.format_url(result&.last_effective_url)

            if web_hsh[:formatted_url].present?
              curl_result[:verified_url] = @web_formatter.convert_to_scheme_host(web_hsh[:formatted_url])
            end
          end

        rescue Timeout::Error # Timeout Exception Handling
          curl_result[:curl_err] = "Error: Timeout"
        end

      rescue LoadError => e  # Curl Exception Handling
        curl_err = error_parser("Error: #{$!.message}")
        # CheckInt.new.check_int if curl_err.include?('TCP')
        curl_result[:curl_err] = curl_err
      end
    else ## If no url present?
      curl_result[:curl_err] = 'URL Nil'
    end

    print_result(curl_result)
    curl_result
  end
```


### Another Example from a Production Environment...

```
  def format_url(url)
    url_hash = @web_formatter.format_url(url)
    url_hash.merge!({ verified_url: nil, url_redirected: false, response_code: nil, url_sts: nil, url_date: Time.now, wx_date: nil, timeout: nil })
    url_hash = evaluate_formatted_url(url_hash)
  end

```



## Author

Adam J Booth  - [4rlm](https://github.com/4rlm)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
