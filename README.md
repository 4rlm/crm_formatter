
# **CRM Formatter**

#### Reformat and Normalize CRM Contact Data, such as Addresses, Phones and URLs.

**CRM Formatter** was originally designed to curate high-volume enterprise-scale asynchronous web scraping via Nokogiri, Mechanize, and Delayed_job.  Web Scraping *aka Web Harvesting / Data Mining* is notoriously unreliable *sticky* work with endless edge-cases to overcome.  Accurately, yet efficiently curating such data is a constant and evolving task, and will continue to be the core functionality of **CRM Formatter**.
However, it also plays an integral role in routine functions of apps, like formatting, normalizing, and even scrubbing existing databases, and submitted form data before saving to the database; via model callbacks, such as `before_validation` or `before_save`.

###### The **CRM Formatter** Gem is currently in `--pre` versioning, aka **beta mode** with frequent updates. Formal tests in the gem environment are still on the way.
However, **CRM Formatter** has been developed continuously for several years and is a reliable and integral part of a production CRM data verification app.  The process of isolating the various modules into a consolidated open source gem has just recently begun, so documentation is still limited, but is frequently being added and refined.

## Getting Started
**CRM Formatter** is compatible with Rails 4.2 and 5.0, 5.1 and 5.2 on Ruby 2.2 and later.

In your Gemfile add:

```
gem 'crm_formatter', '~> 1.0.6.pre.rc.1'
```

Or to install locally:

```
gem install crm_formatter --pre
```

## Usage

##### Usage is organized into three sections, Overview, Methods and Examples.

### I. Overview

#### 1. Access and Integration
##### Using **CRM Formatter** in your app is very simple, and could be accessed from your app's concerns, controllers, helpers, lib, models, or services, but depends on the scope, location, and size of your application and server.    
  * Simple form submission validations: model callback typically ideal.
  * Database normalizing tasks: wrapper method in concerns, helpers, or lib typically ideal.
  * Long running processes like web scraping or high volume APIs calls, like Google Linkedin, or Twitter: the lib or services might be ideal (multithreaded asynchronously even better)

#### 2. Hash Response
##### Formatted data will always be returned as a hash datatype the following key-value pairs:
  * The originally submitted data as the first pair.
  * Formatted data in the remaining pairs.
  * A T/F boolean indicator pair regarding if the original and formatted data are different.

#### 3. Optional Arguments *OA*
##### A class can be instantiated with optional arguments *OA*.
  * OA accepts data in the hash datatype, aka 'keyword-args'.
  * Available Web OA: url_flags, link_flags, href_flags, extension_flags, length_min, length_max
  * 'Flag' is for 'Red Flags', or a list of criteria to compare with.  
  * For example, you might want to know which URLs contain 'twitter', 'facebook', or 'linkedin' either to focus on developing a list of business social media links, or perhaps you want to use such a list to better avoid such links.
  * *OA is currently only available for the Web class.*
  * *Address OA & Phone OA will be available in a future release.*

### II. Methods
##### CRM Formatter**'s top level module is `CRMFormatter` and contains the following three classes:
1. Address:  `CRMFormatter::Address.new`
2. Phone:  `CRMFormatter::Address.new`
3. Web:  `CRMFormatter::Address.new`

###### Then assign the above to a variable name of your choosing.
`addr_formatter = CRMFormatter::Address.new`
`@addr_formatter = CRMFormatter::Address.new`

###### Web accepts optional arguments *OA* as a Hash (with Key-Value pairs)
Without OA: Instantiate normally if not using OA.
`web_formatter = CRMFormatter::Web.new`

With OA: Follow the steps to use Web OA:
1. Available Web OA and the required Key-Value naming and datatypes.  
* Only list the OA K-V Pairs you're using.  No need to list empty values.  It's not all or nothing. These are empty to illustrate the expected datatypes.

Available:
`oa_args = { url_flags: [], link_flags: [], href_flags: [], extension_flags: [], length_min: integer, length_max: integer }`


Example:
```
oa_args = { url_flags: %w(approv insur invest loan quick rent repair),
            link_flags: %w(buy call cash cheap click gas insta),
            href_flags: %w(after anounc apply approved blog buy call click),
            extension_flags: %w(au ca edu es gov in ru uk us),
            length_min: 0,
            length_max: 30
          }

@web_formatter = CRMFormatter::Web.new(oa_args)
```




#### 1. Address Methods

'get_full_address()' takes a hash of address parts then runs each through their respective formatters, then also adds an additional feature of combining them into a long full address string, and indicates if there were any changes from the original version and newly formatted.

```
  addr_formatter = CRMFormatter::Address.new

  full_address_hash = {street: street, city: city, state: state, zip: zip}

  addr_formatter.get_full_address(full_address_hash)

  addr_formatter.format_street(street_string)

  addr_formatter.format_city(city_string)

  addr_formatter.format_state(state_string)

  addr_formatter.format_zip(zip)

  addr_formatter.format_full_address(adr = {})

  addr_formatter.compare_versions(original, formatted)


```

#### Phone Methods

Subtle but important distinction between 'format_phone' which simply puts a phone in any format, like 555-123-4567 into normalized (555) 123-4567, and 'validate_phone' which also uses 'format_phone' to normalize its output, but is mainly tasked with determining if the phone number seem legitimate. If you know for sure that it is a phone number, but just want to normalize then first try format_phone.  If you are doing web scraping or throwing in strings of text mixed with phones, then validate_phone might work better.

```
  ph_formatter = CRMFormatter::Phone.new

  ph_formatter.validate_phone(phone)

  ph_formatter.format_phone(phone)

```

#### Web Methods



```
  web_formatter = CRMFormatter::Web.new

  web_formatter.format_url(url)

  web_formatter.extract_link(url_path)

  web_formatter.remove_invalid_links(link)

  web_formatter.remove_invalid_hrefs(href)

  web_formatter.convert_to_scheme_host(url)

```


### III. Examples
Some of the examples are excessively verbose to help illustrate the datatypes and processes.  Here are a few guidelines and tips:
** These are just examples below, not strict usage guides ...


#### 1. Address Examples

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



#### 2. Phone Examples

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


#### 3. Web Examples

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


Another example below.

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

##### Fully Integrated into an App Example

** The gem is currently being used within another app in the following way...

```
  @web_formatter.convert_to_scheme_host(url)
  @web_formatter.format_url(url)
```

** The two methods above, which are many available to you in the gem are being used below.

```
  curl_result[:response_code] = result&.response_code.to_s
  web_hsh = @web_formatter.format_url(result&.last_effective_url)

  if web_hsh[:formatted_url].present?
    curl_result[:verified_url] = @web_formatter.convert_to_scheme_host(web_hsh[:formatted_url])
  end

```

** Above is an isolated sliver of the larger environment shown below...

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

** Another Example from a Production Environment...

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
