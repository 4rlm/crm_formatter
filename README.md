
# CRM Formatter

##### Efficiently Reformat, Normalize, and Scrub CRM Contact Data, such as Addresses, Phones and URLs.

##### CRM Formatter is perfect for curating high-volume enterprise-scale web scraping, and integrates well with Nokogiri, Mechanize, and asynchronous jobs via Delayed_job or SideKick, to name a few.  Web Scraping and Harvesting often gathers a lot of junk to sift through; presenting unexpected Edge-Cases around each corner.  CRM Formatter has been developed and refined during the past few years to focus on improving that task.

##### It's also perfect for processing API data, Web Forms, and routine DB normalizing and scrubbing processes.  Not only does it reformat Address, Phone, and Web data, it can also accept lists to scrub against, then providing detailed reports about how each piece of data compares with your criteria lists.

##### The CRM Formatter Gem is currently in '--pre versioning', or 'beta mode' as the process of reorganizing these proprietary, production environment processes from their native app environment into this newly created open source gem.  Formal tests in the gem environment are still on the way, as is the documentation.  But the processes themselves have been very reliable and an integral part of a very large app dedicated to such services.  Please feel free to give it a try!  Hopefully it will provide you and your organization some relief!

## Getting Started
#### CRM Formatter is compatible with Rails 4.2 and 5.0, 5.1 and 5.2 on Ruby 2.2 and later.

#### In your Gemfile add:

```
gem 'crm_formatter', '~> 1.0.6.pre.rc.1'
```

#### Or to install locally:

```
gem install crm_formatter --pre
```

## Usage

##### Usage is organized into three sections, Overview, Methods and Examples.

### I. Overview


#### Access and Integration

###### Using CRM Formatter in your app is very simple, and could be accessed from your app's concerns, controllers, helpers, lib, models, or services, but depends on the scope, location, and size of your application and server.    
* Simple form submission validations: model callback typically ideal.
* Database normalizing tasks: wrapper method in concerns, helpers, or lib typically ideal.
* Long running processes like web scraping or high volume APIs calls, like Google Linkedin, or Twitter: the lib or services might be ideal (multithreaded asynchronously even better)


### II. Methods

#### Available to Classes
The top level module is named CRMFormatter, which contains the following three classes, accessible in the following way:

```
CRMFormatter::Address.new
CRMFormatter::Address.new
CRMFormatter::Address.new
```

#### Assign to Variables
Assign the above to local or instant variables like below.  You can name them anything you like.

```
adr_formatter = CRMFormatter::Address.new
@adr_formatter = CRMFormatter::Address.new

ph_formatter = CRMFormatter::Phone.new
@ph_formatter = CRMFormatter::Phone.new

web_formatter = CRMFormatter::Web.new
@web_formatter = CRMFormatter::Web.new
```

#### Creating a Class and Method as a Wrapper
You might like to create a dedicated class for the purpose of queueing, running, and saving the results. Typically, concerns, controllers, helpers, lib, models, or services are good places, but depends on your specifications.

```
# /app/lib/start_crm.rb
```

```
class StartCrm

  def initialize
    @web = CRMFormatter::Web.new
  end

  def run_webs

    formatted_url_hashes = urls.map do |url|
      url_hash = @web.format_url(url)
    end

  end

end
```
#### Application Config
Make sure to modify your application config file to recognize your new class if need be.

```
#/app/config/application.rb

config.eager_load_paths << Rails.root.join('lib/**')
config.eager_load_paths += Dir["#{config.root}/lib/**/"]
```

#### Run in Rails Console
You could run the process through your contoller actions in a GUI, or in scheduled Cron Jobs.  But for this example, we'll run it in Rails Console like below.

```
2.5.1 :001 > StartCrm.new.run_webs
```

#### Instance vs Class Method Wrapper
In the above example, `run_webs` is an instance method, but could work well as a class method `self.run_webs` too; thus not requiring initializing.  The structure would be a little different, but a little less to type in Rails C if you were inclined to run it like so.  Next you could setup your class with various methods to assist your process, like so:

```
class StartCrm

  def self.run_webs
    web = CRMFormatter::Web.new

    formatted_url_hashes = query_accounts.map do |act|
      url_hsh = web.format_url(act.url)

      if url_hash[:is_reformatted]

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

#### Data Response as Hash
All data in CRM Formatter is returned as a hash and includes your unaltered original data submitted, the formatted data, a T/F boolean indicator regarding if the original and formatted data are different, and for some methods, negs and pos regarding your criteria to scrub against.

In the above example, the returned data from each submitted url would resemble the one below.
```
# format_url method returns data like below this example...
# url_hash = {:is_reformatted=>false,
    :url_path=>"https://www.steXXXXXXmitsubishiserviceandpartscenter.com",
    :formatted_url=>"https://www.steXXXXXXmitsubishiserviceandpartscenter.com",
    :neg=>["neg_urls: parts, rv, service"],
    :pos=>["pos_urls: mitsubishi"]
  }

```

#### Optional Arguments OA
A class can be instantiated with optional arguments 'OA', to load your criteria to scrub against. Only list the OA K-V Pairs you're using.  No need to list empty values.  It's not all or nothing. These are empty to illustrate the expected datatypes. *OA is currently only available for the Web class, but will soon be available in the Address & Phone classes.*

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

@web_formatter = CRMFormatter::Web.new(oa_args)

```

#### 1. Address Methods
`get_full_address()` takes a hash of address parts then runs each through their respective formatters, then also adds an additional feature of combining them into a long full address string, and indicates if there were any changes from the original version and newly formatted.

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
**3. Web Examples at the very bottom is the most detailed and recent.  It might be a good place to start.**
*These are just examples below, not strict usage guides ...*

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
The steps below will show you an option for how you could integrate larger processes in your app.  Create a wrapper method you can call from an action or Rails C. In this example, a new class was also created in Lib for that purpose, as there could be related methods to create.  

```
# /app/lib/start_crm.rb

class StartCrm

  ##Rails C: StartCrm.run_webs
  def self.run_webs
    oa_args = get_args
    web = CRMFormatter::Web.new(oa_args)

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

Results are always in a Hash, like below.  The URLs are slightly obfuscated out of respect (it's not a bug).  These are examples from a large DB that runs on a loop 24/7 and gets to each organization about once a week, so it's already pretty well up to date, so there aren't any big changes below, but there are still a few things to point out.

`:is_reformatted` indicates T/F if url_path and `:formatted_url` differ.  If False, then it means they are the same, or the `:url_path` had significant errors which prevented it from being formatted, thus `:formatted_url` would be nil in such a case.  The reality is that you might have some URLs that are so far off that, that they can't be reliably reformatted, so better to only let them pass if we are confident that they are reliable.

`:url_path` is the url originally submitted by the client.  It can include directory links on the end too, '/careers/, '/about-us/', etc.

`:formatted_url` is the formatted version of `:url_path`.  It will be stripped of additional paths, '/deals/', '/staff/', etc.  Also, often times people ommit 'http://:' and 'www' in CRMs.  This can sometimes cause errors for users or Mechanized Web Scrapers.  So, those will always be included to ensure consistency.  In our production app we follow up the formatting with url redirect following, which our configurations require the entire path, so it will always be included.  The redirect following gem is already being worked on and will be released as an additional gem shortly.

`:neg` is an array of all the errors and negative, undesirable criteria to scrub against.  If you include the criteria in OA `neg_urls:`, like above, it will automatically scrub and report.  Regardless, any errors will also be included in there.  So, if the url was not ultimately formatted, there will be details regarding why in `:neg`.

`:pos` is the opposite, which highlights positive criteria you might be looking for.  It too is available in OA via `pos_urls:`, like above.

```
[ {:is_reformatted=>false,
    :url_path=>"https://www.steXXXXXXmitsubishiserviceandpartscenter.com",
    :formatted_url=>"https://www.steXXXXXXmitsubishiserviceandpartscenter.com",
    :neg=>["neg_urls: parts, rv, service"],
    :pos=>["pos_urls: mitsubishi"]},

   {:is_reformatted=>false,
    :url_path=>"https://www.perXXXXXXchryslerjeepcenterville.com",
    :formatted_url=>"https://www.perXXXXXXchryslerjeepcenterville.com",
    :neg=>["neg_urls: rv"],
    :pos=>["pos_urls: chrysler, jeep"]},

   {:is_reformatted=>false,
    :url_path=>"http://www.pXXXXXXchryslerjeepcenterville.com",
    :formatted_url=>"http://www.XXXXXXechryslerjeepcenterville.com",
    :neg=>["neg_urls: rv"],
    :pos=>["pos_urls: chrysler, jeep"]},

   {:is_reformatted=>false,
    :url_path=>"http://www.colXXXXXXchryslerdodgejeepram.com",
    :formatted_url=>"http://www.colXXXXXXchryslerdodgejeepram.com",
    :neg=>["neg_urls: rv"],
    :pos=>["pos_urls: chrysler, dodge, jeep, ram"]}
  ]
```


## Author

Adam J Booth  - [4rlm](https://github.com/4rlm)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
