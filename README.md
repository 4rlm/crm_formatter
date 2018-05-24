
# CRM Formatter
#### Efficiently Reformat, Normalize, and Scrub CRM Contact Data, such as Addresses, Phones and URLs.

CRM Formatter is perfect for curating high-volume enterprise-scale web scraping, and integrates well with Nokogiri, Mechanize, and asynchronous jobs via Delayed_job or SideKick, to name a few.  Web Scraping and Harvesting often gathers a lot of junk to sift through; presenting unexpected edge cases around each corner.  CRM Formatter has been developed and refined during the past few years to focus on improving that task.

It's also perfect for processing API data, Web Forms, and routine DB normalizing and scrubbing processes.  Not only does it reformat Address, Phone, and Web data, it can also accept lists to scrub against, then providing detailed reports about how each piece of data compares with your criteria lists.

The CRM Formatter Gem is currently in '--pre versioning', or 'beta mode' as the process of reorganizing these proprietary, production environment processes from their native app environment into this newly created open source gem.  Formal tests in the gem environment are still on the way, as is the documentation.  But the processes themselves have been very reliable and an integral part of a very large app dedicated to such services.  

## Getting Started
CRM Formatter is compatible with Rails 4.2 and 5.0, 5.1 and 5.2 on Ruby 2.2 and later.

In your Gemfile add:
```
gem 'crm_formatter', '~> 1.0.8.pre.rc.1'
```
Or to install locally:
```
gem install crm_formatter --pre
```
## Usage
Using CRM Formatter in your app is very simple, and could be accessed from your app's concerns, , helpers, lib, models, or services, but depends on the scope, location, and size of your application and server. For simple form submission validations the model callback is typically ideal.  For database normalizing tasks the concerns, helpers, or lib is typically ideal.  For long running processes like web scraping or high volume APIs calls, like Google Linkedin, or Twitter  the lib or services might be ideal (asynchronous multithreaded even better)

### Class Names
CrmFormatter contains three classes, which can be accessed like below with local or instance variables; you can name them anything you like.
```
adr_formatter = CrmFormatter::Address.new
@adr_formatter = CrmFormatter::Address.new

ph_formatter = CrmFormatter::Phone.new
@ph_formatter = CrmFormatter::Phone.new

web_formatter = CrmFormatter::Web.new
@web_formatter = CrmFormatter::Web.new
```

### Available Methods in Each Class

## Address Methods
These are the methods available to you.  You can use them a la cart, for example if you just wanted to format all your states, or you could combine the entire address into `get_full_address()` which will run each of the related methods for you.  It also adds an additional hash pair containing the full address as a single string.  There is also an indicator pair to report if there were any changes from the original version to the newly formatted.
```
  addr_formatter = CrmFormatter::Address.new
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
Phone only has two methods, with a subtle but important distinction between them.  For simply formatting a known phone, use `format_phone` to convert to the normalized (555) 123-4567 format.  Use `validate_phone` if either your phone data has a bunch of text and special characters to remove, or if you aren't even sure that it is a phone, as it will help determine if the phone number seem legitimate.  If so, it then passes it along to `format_phone`.
```
  ph_formatter = CrmFormatter::Phone.new
  ph_formatter.validate_phone(phone)
  ph_formatter.format_phone(phone)
```

#### Web Methods
The examples on this README are from `format_url` method.  The others are for web scraping, which will be documented in the near future.
```
  web_formatter = CrmFormatter::Web.new
  web_formatter.format_url(url)
  web_formatter.extract_link(url_path)
  web_formatter.remove_invalid_links(link)
  web_formatter.remove_invalid_hrefs(href)
  web_formatter.convert_to_scheme_host(url)
```

## Examples
#### Below are two examples using the Web `format_url(url)` method:

### Example 1: 6 Example URLs Submitted:
Custom Method to Query URLs
```
def self.get_urls
  urls = %w(website.com website.business.site website website.fake website.fake.com website.com.fake)
end
```
Custom Wrapper Method
```
def self.run_webs
  web = CrmFormatter::Web.new
  formatted_url_hashes = get_urls.map do |url|
    url_hash = web.format_url(url)
  end
end
```
Results as Hash: 3/6 Reformatted due to invalid or no url extensions. 3 Reformatted and Normalized with `http://www.`  
URL Extensions, **.com, .net, .fake** cross referenced with official IANA list.
```
[ {:reformatted=>true, :url_path=>"website.com", :formatted_url=>"http://www.website.com", :neg=>[], :pos=>[]},
  {:reformatted=>false, :url_path=>"website.business.site", :formatted_url=>nil, :neg=>["error: ext.valid > 1 [business, site]"], :pos=>[]}, {:reformatted=>false, :url_path=>"website", :formatted_url=>nil, :neg=>["error: ext.none"], :pos=>[]},
  {:reformatted=>false, :url_path=>"website.fake", :formatted_url=>nil, :neg=>["error: ext.invalid [fake]"], :pos=>[]},
  {:reformatted=>true, :url_path=>"website.fake.com", :formatted_url=>"http://www.website.com", :neg=>[], :pos=>[]},
  {:reformatted=>true, :url_path=>"website.com.fake", :formatted_url=>"http://www.website.com", :neg=>[], :pos=>[]}
]
```

### Example 2: 6 Real URLs with Scrubbing Feature, but same configuration as above:
**Intentionally partially obfuscated**
```
urls = %w(approvXXXutosales.org autXXXartfinance.com leXXXummitautorepair.net melXXXtoyota.com norXXXastacura.com XXXmazda.com)
```
These results list 'neg' and 'pos', which are the criteria I was scrubbing against.  I wanted to find the URLs of franchise auto dealers and exclude ancillary URLs.
```
[{:reformatted=>true, :url_path=>"approvXXXutosales.org", :formatted_url=>"http://www.approvXXXutosales.org", :neg=>["neg_urls: approv"], :pos=>[]},
 {:reformatted=>true, :url_path=>"autXXXartfinance.com", :formatted_url=>"http://www.autXXXartfinance.com", :neg=>["neg_urls: financ"], :pos=>["pos_urls: smart"]},
 {:reformatted=>true, :url_path=>"leXXXummitautorepair.net", :formatted_url=>"http://www.leXXXummitautorepair.net", :neg=>["neg_urls: repair"], :pos=>[]},
 {:reformatted=>true, :url_path=>"melXXXtoyota.com", :formatted_url=>"http://www.melXXXtoyota.com", :neg=>[], :pos=>["pos_urls: toyota"]},
 {:reformatted=>true, :url_path=>"norXXXastacura.com", :formatted_url=>"http://www.norXXXastacura.com", :neg=>[], :pos=>["pos_urls: acura"]},
 {:reformatted=>true, :url_path=>"XXXmazda.com", :formatted_url=>"http://www.XXXmazda.com", :neg=>[], :pos=>["pos_urls: mazda"]}
 ]
```

## Quick Setup Guide

#### Create a Wrapper with a custom Class and Method(s)
This is just one of several ways to configure.  If you only need the gem for formatting form data, you could just create a callback method in your model, but to scrub a database or process API and Harvested data, you'll want a dedicated process so you can manage the queue, criteria, and results.  If you don't already have one, this example will show you how. Concerns, Helpers and Models might be fine for smaller tasks, but for heavier tasks Lib and Services are ideal, but depends on your specifications.
```
# /app/lib/start_crm.rb
```
```
class StartCrm
  def initialize
    @web = CrmFormatter::Web.new
  end

  def run_webs
    formatted_url_hashes = urls.map do |url|
      url_hash = @web.format_url(url)
    end
  end
end
```
You may need to edit your application config file to recognize your new class.
```
#/app/config/application.rb

config.eager_load_paths << Rails.root.join('lib/**')
config.eager_load_paths += Dir["#{config.root}/lib/**/"]
```
#### Run in Rails Console
In this example, we'll run it in Rails Console like below, but you could also create a Rake Task and integrate it with a scheduled Cron Job.  You could also run the process through your contoller actions in a GUI. If accessing through the front end, you might want to do it asynchronously with gems like Delayed_job or SideKick so you can free-up your controllers and prevent your front end from freezing while waiting for the job to complete; if running very large tasks.
```
2.5.1 :001 > StartCrm.new.run_webs
```
#### Instance vs Class Methods in your Wrapper
In the above example, `run_webs` is an instance method, but a class method `self.run_webs` could work well too, like the example below.  At lease in the early stages, this is a little easier if you keep running it in Rails C, because not requiring initializing means less to type to call it.  Next you could setup your class with various methods to assist your process, like so:
```
class StartCrm
  def self.run_webs
    web = CrmFormatter::Web.new

    formatted_url_hashes = query_accounts.map do |act|
      url_hsh = web.format_url(act.url)

      if url_hash[:reformatted]

        act_hsh = { url: url_hsh[:formatted_url],
                    url_sts: url_hsh[:formatted_url],
                    scrub_date: Time.now
                  }
      else
        act_hsh = { scrub_date: Time.now }
      end

      act.update(act_hsh)
    end
  end

  def self.query_accounts
    accounts = Account.where(url_sts: 'Invalid').limit(50)
  end
end
```

#### Data Response in a Hash
CRM Formatter returns data as a hash, which includes your original unaltered data you submitted, the formatted data, a T/F boolean indicator regarding if the original and formatted data are different, and for some methods, negs and pos regarding your criteria to scrub against.  In the above example, the returned data from each submitted url would resemble the one below.
```
# format_url method returns data like below this example...
# url_hash = {:reformatted=>false,
    :url_path=>"https://www.steXXXXXXmitsubishiserviceandpartscenter.com",
    :formatted_url=>"https://www.steXXXXXXmitsubishiserviceandpartscenter.com",
    :neg=>["neg_urls: parts, rv, service"],
    :pos=>["pos_urls: mitsubishi"]
  }
```

#### Optional Arguments OA
A class can be instantiated with optional arguments 'OA', to load your criteria to scrub against. Only list the OA K-V Pairs you're using.  No need to list empty values.  It's not all or nothing. These are empty to illustrate the expected datatypes.
**OA is currently only available for the Web class, but will soon be available in the Address & Phone classes.**

Below is how the OA are received in the Web class at initialization.
```
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
```

Below is the syntax for how to use OA. Positive and Negative options available, and essentially function the same, but allow additional options for scrubbing data.
```
oa_args = { neg_urls: %w(approv insur invest loan quick rent repair),
            neg_links: %w(buy call cash cheap click gas insta),
            neg_hrefs: %w(after anounc apply approved blog buy call click),
            neg_exts: %w(au ca edu es gov in ru uk us),
            min_length: 0,
            max_length: 30
          }
@web_formatter = CrmFormatter::Web.new(oa_args)
```

### III. Detailed Examples
Some of the examples are excessively verbose to help illustrate the datatypes and processes.  Here are a few guidelines and tips:

*These are just examples, not strict usage guides ...*

#### 1. Address Examples
```
def self.run_adrs

  crm_address_formatter = CrmFormatter::Address.new

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
@crm_phone = CrmFormatter::Phone.new

def self.format_all_phone_in_my_db
  phones_from_contacts = Contacts.where.not(phone: nil)

  phones_from_contacts.each do |contact|
    phone_hash = @crm_phone.validate_phone(contact.phone)  
  end

end

phone_hash = { phone: 555-123-4567, phone_crmf: (555) 123-4567, phone_status: true }
```

#### 3. Web Examples
The steps below will show you an option for how you could integrate larger processes in your app.  Create a wrapper method you can call from an action or Rails C. In this example, a new class was also created in Lib for that purpose, as there could be related methods to create.  
```
# /app/lib/start_crm.rb

class StartCrm

  ##Rails C: StartCrm.run_webs
  def self.run_webs
    oa_args = get_args
    web = CrmFormatter::Web.new(oa_args)

    formatted_url_hashes = get_urls.map do |url|
      url_hash = web.format_url(url)
    end

    formatted_url_hashes
  end

end
```
Application Config
```
#/app/config/application.rb

config.eager_load_paths << Rails.root.join('lib/**')
config.eager_load_paths += Dir["#{config.root}/lib/**/"]
```
Create your db query or put together a list of URLs to process, along with any OA to include.  The below example is very verbose, but designed to be helpful. In reality, you might have various criteria saved in the db rather than writing it out.
In this example, we have auto dealer URLs.  In this process, we're focusing on franchise dealers.
```
def self.get_args
  neg_urls = %w(approv avis budget collis eat enterprise facebook financ food google gourmet hertz hotel hyatt insur invest loan lube mobility motel motorola parts quick rent repair restaur rv ryder service softwar travel twitter webhost yellowpages yelp youtube)

  pos_urls = ["acura", "alfa romeo", "aston martin", "audi", "bmw", "bentley", "bugatti", "buick", "cdjr", "cadillac", "chevrolet", "chrysler", "dodge", "ferrari", "fiat", "ford", "gmc", "group", "group", "honda", "hummer", "hyundai", "infiniti", "isuzu", "jaguar", "jeep", "kia", "lamborghini", "lexus", "lincoln", "lotus", "mini", "maserati", "mazda", "mclaren", "mercedes-benz", "mitsubishi", "nissan", "porsche", "ram", "rolls-royce", "saab", "scion", "smart", "subaru", "suzuki", "toyota", "volkswagen", "volvo"]

  neg_exts = %w(au ca edu es gov in ru uk us)
  oa_args = {neg_urls: neg_urls, pos_urls: pos_urls, neg_exts: neg_exts}
end

def self.get_urls
  urls = ["https://www.stevXXXXXXmitsubishiserviceandpartscenter.com", "https://www.perXXXXXXchryslerjeepcenterville.com", "http://www.peXXXXXXchryslerjeepcenterville.com", "http://www.colXXXXXXchryslerdodgejeepram.com"]
end
```
Run your class and wrapper method in Rails C.  By creating the wrapper method, you have set up the entire process to run like a runner.  In reality, you might have several different criteria accessible from a GUI or even running in Cron Jobs.
```
2.5.1 :001 > StartCrm.run_webs
```
Results are always in a Hash, like below.  The URLs are slightly obfuscated out of respect (it's not a bug).  These are examples from a large DB that runs on a loop 24/7 and gets to each organization about once a week, so it's already pretty well up to date, so there aren't any big changes below, but there are still a few things to point out below the code example.
```
[ {:reformatted=>false,
    :url_path=>"https://www.steXXXXXXmitsubishiserviceandpartscenter.com",
    :formatted_url=>"https://www.steXXXXXXmitsubishiserviceandpartscenter.com",
    :neg=>["neg_urls: parts, rv, service"],
    :pos=>["pos_urls: mitsubishi"]},

   {:reformatted=>false,
    :url_path=>"https://www.perXXXXXXchryslerjeepcenterville.com",
    :formatted_url=>"https://www.perXXXXXXchryslerjeepcenterville.com",
    :neg=>["neg_urls: rv"],
    :pos=>["pos_urls: chrysler, jeep"]},

   {:reformatted=>false,
    :url_path=>"http://www.pXXXXXXchryslerjeepcenterville.com",
    :formatted_url=>"http://www.XXXXXXechryslerjeepcenterville.com",
    :neg=>["neg_urls: rv"],
    :pos=>["pos_urls: chrysler, jeep"]},

   {:reformatted=>false,
    :url_path=>"http://www.colXXXXXXchryslerdodgejeepram.com",
    :formatted_url=>"http://www.colXXXXXXchryslerdodgejeepram.com",
    :neg=>["neg_urls: rv"],
    :pos=>["pos_urls: chrysler, dodge, jeep, ram"]}
  ]
```
`:reformatted` indicates T/F if url_path and `:formatted_url` differ.  If False, then it means they are the same, or the `:url_path` had significant errors which prevented it from being formatted, thus `:formatted_url` would be nil in such a case.  The reality is that you might have some URLs that are so far off that, that they can't be reliably reformatted, so better to only let them pass if we are confident that they are reliable.

`:url_path` is the url originally submitted by the client.  It can include directory links on the end too, '/careers/, '/about-us/', etc.

`:formatted_url` is the formatted version of `:url_path`.  It will be stripped of additional paths, '/deals/', '/staff/', etc.  Also, often times people ommit 'http://:' and 'www' in CRMs.  This can sometimes cause errors for users or Mechanized Web Scrapers.  So, those will always be included to ensure consistency.  In our production app we follow up the formatting with url redirect following, which our configurations require the entire path, so it will always be included.  The redirect following gem is already being worked on and will be released as an additional gem shortly.

`:neg` is an array of all the errors and negative, undesirable criteria to scrub against.  If you include the criteria in OA `neg_urls:`, like above, it will automatically scrub and report.  Regardless, any errors will also be included in there.  So, if the url was not ultimately formatted, there will be details regarding why in `:neg`.

`:pos` is the opposite, which highlights positive criteria you might be looking for.  It too is available in OA via `pos_urls:`, like above.


## Author

Adam J Booth  - [4rlm](https://github.com/4rlm)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
