
# CrmFormatter

[![Build Status](https://travis-ci.org/4rlm/crm_formatter.svg?branch=master)](https://travis-ci.org/4rlm/crm_formatter)
[![Gem Version](https://badge.fury.io/rb/crm_formatter.svg)](https://badge.fury.io/rb/crm_formatter)

#### Efficiently Reformat, Normalize, and Scrub CRM Contact Data, such as Addresses, Phones and URLs.

CrmFormatter is perfect for curating high-volume enterprise-scale web scraping, and integrates well with Nokogiri, Mechanize, and asynchronous jobs via Delayed_job or SideKick, to name a few.  Web Scraping and Harvesting often gathers a lot of junk to sift through; presenting unexpected edge cases around each corner.  CrmFormatter has been developed and refined during the past few years to focus on improving that task.

It's also perfect for processing API data, Web Forms, and routine DB normalizing and scrubbing processes.  Not only does it reformat Address, Phone, and Web data, it can also accept lists to scrub against, then providing detailed reports about how each piece of data compares with your criteria lists.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crm_formatter'
```

And then execute:
```
  $ bundle
```

Or install it yourself as:
```
  $ gem install crm_formatter
```

## Usage

### I. Basic Usage
Basic methods available are:
```
format_addresses(array_of_addresses)
format_phones(array_of_phones)
format_propers(array_of_propers)
format_urls(array_of_urls)
```

1. Format Array of Proper Strings:

Use `format_propers` to format strings with proper nouns, such as (but not limited to):

Business Account Names (123 bmw-world => 123 BMW-World),

Proper Names (adam john booth => Adam John Booth),

Job Titles (marketing director => Marketing Director),

Article Titles (the 15 most useful ruby methods => The 15 Most Useful Ruby Methods)

```
array_of_propers = [
  'the gmc and bmw-world of AUSTIN tx',
  '123 Car-world Kia OF CHICAGO IL',
  'Main Street Ford in DALLAS tX',
  'broad st fiat of houston',
  'hot-deal auto insurance',
  'BUDGET - AUTOMOTORES ZONA & FRANCA, INC',
  'DOWNTOWN CAR REPAIR, INC',
  'Young Gmc Trucks',
  'TEXAS TRAVEL, CO',
  'youmans Chevrolet',
  'quick auto approval, inc',
  'yazell chevy',
  'quick cAr LUBE',
  'yAtEs AuTo maLL',
  'YADKIN VALLEY COLLISION CO',
  'XIT FORD INC'
]

formatted_proper_hashes = CrmFormatter.format_propers(array_of_propers)
```

Formatted Proper Strings:

```
formatted_proper_hashes =
[
  {
    proper_status: 'formatted',
    proper: 'the gmc and bmw-world of AUSTIN tx',
    proper_f: 'The GMC and BMW-World of Austin TX'
  },
  {
    proper_status: 'formatted',
    proper: '123 Car-world Kia OF CHICAGO IL',
    proper_f: '123 Car-World Kia of Chicago IL'
  },
  {
    proper_status: 'formatted',
    proper: 'Main Street Ford in DALLAS tX',
    proper_f: 'Main Street Ford in Dallas TX'
  },
  {
    proper_status: 'formatted',
    proper: 'broad st fiat of houston',
    proper_f: 'Broad St Fiat of Houston'
  },
  {
    proper_status: 'formatted',
    proper: 'hot-deal auto insurance',
    proper_f: 'Hot-Deal Auto Insurance'
  },
  {
    proper_status: 'formatted',
    proper: 'BUDGET - AUTOMOTORES ZONA & FRANCA, INC',
    proper_f: 'Budget - Automotores Zona & Franca, Inc'
  },
  {
    proper_status: 'formatted',
    proper: 'DOWNTOWN CAR REPAIR, INC',
    proper_f: 'Downtown Car Repair, Inc'
  },
  {
    proper_status: 'formatted',
    proper: 'Young Gmc Trucks',
    proper_f: 'Young GMC Trucks'
  },
  {
    proper_status: 'formatted',
    proper: 'TEXAS TRAVEL, CO',
    proper_f: 'Texas Travel, Co'
  },
  {
    proper_status: 'formatted',
    proper: 'youmans Chevrolet',
    proper_f: 'Youmans Chevrolet'
  },
  {
    proper_status: 'formatted',
    proper: 'quick auto approval, inc',
    proper_f: 'Quick Auto Approval, Inc'
  },
  {
    proper_status: 'formatted',
    proper: 'yazell chevy',
    proper_f: 'Yazell Chevy'
  },
  {
    proper_status: 'formatted',
    proper: 'quick cAr LUBE',
    proper_f: 'Quick Car Lube'
  },
  {
    proper_status: 'formatted',
    proper: 'yAtEs AuTo maLL',
    proper_f: 'Yates Auto Mall'
  },
  {
    proper_status: 'formatted',
    proper: 'YADKIN VALLEY COLLISION CO',
    proper_f: 'Yadkin Valley Collision Co'
  },
  {
    proper_status: 'formatted',
    proper: 'XIT FORD INC',
    proper_f: 'Xit Ford Inc'
  }
]
```

2. Format Array of Phone Numbers:

```
array_of_phones = %w[
  555-457-4391
  555-888-4391
  555-457-4334
  555-555
  555.555.1234
  not_a_number
]

formatted_phone_hashes = CrmFormatter.format_phones(array_of_phones)
```

Formatted Phone Numbers:

```
formatted_phone_hashes = [
  {
    phone_status: 'formatted',
    phone: '555-457-4391',
    phone_f: '(555) 457-4391'
  },
  {
    phone_status: 'formatted',
    phone: '555-888-4391',
    phone_f: '(555) 888-4391'
  },
  {
    phone_status: 'formatted',
    phone: '555-457-4334',
    phone_f: '(555) 457-4334'
  },
  {
    phone_status: 'invalid',
    phone: '555-555',
    phone_f: nil
  },
  {
    phone_status: 'formatted',
    phone: '555.555.1234',
    phone_f: '(555) 555-1234'
  },
  {
    phone_status: 'invalid',
    phone: 'not_a_number',
    phone_f: nil
  }
]
```

3. Format Array of URLs:

```
array_of_urls = %w[
  sample01.com/staff
  www.sample02.net.com
  http://www.sample3.net
  www.sample04.net/contact_us
  http://sample05.net
  www.sample06.sofake
  www.sample07.com.sofake
  example08.not.real
  www.sample09.net/staff/management
  www.www.sample10.com
]

formatted_url_hashes = CrmFormatter.format_urls(array_of_urls)
```

Formatted URLs:

```
formatted_url_hashes = [
  {
    web_status: 'invalid',
    url: 'www.sample01.net.com',
    url_f: nil,
    url_path: nil,
    web_neg: 'error: ext.valid > 1 [com, net]'
  },
  {
    web_status: 'formatted',
    url: 'sample02.com',
    url_f: 'http://www.sample02.com',
    url_path: nil,
    web_neg: nil
  },
  {
    web_status: 'unchanged',
    url: 'http://www.sample3.net',
    url_f: 'http://www.sample3.net',
    url_path: nil,
    web_neg: nil
  },
  {
    web_status: 'formatted',
    url: 'www.sample04.net/contact_us',
    url_f: 'http://www.sample04.net',
    url_path: '/contact_us',
    web_neg: nil
  },
  {
    web_status: 'formatted',
    url: 'http://sample05.net',
    url_f: 'http://www.sample05.net',
    url_path: nil,
    web_neg: nil
  },
  {
    web_status: 'invalid',
    url: 'www.sample06.sofake',
    url_f: nil,
    url_path: nil,
    web_neg: 'error: ext.invalid [sofake]'
  },
  {
    web_status: 'formatted',
    url: 'www.sample07.com.sofake',
    url_f: 'http://www.sample07.com',
    url_path: nil,
    web_neg: nil
  },
  {
    web_status: 'invalid',
    url: 'example08.not.real',
    url_f: nil,
    url_path: nil,
    web_neg: 'error: ext.invalid [not, real]'
  },
  {
    web_status: 'formatted',
    url: 'www.sample09.net/staff/management',
    url_f: 'http://www.sample09.net',
    url_path: '/staff/management',
    web_neg: nil
  },
  {
    web_status: 'formatted',
    url: 'www.www.sample10.com',
    url_f: 'http://www.sample10.com',
    url_path: nil,
    web_neg: nil
  }
]
```

4. Format Array of Addresses (each as a hash):

```
array_of_addresses = [
  { street: '1234 EAST FAIR BOULEVARD', city: 'AUSTIN', state: 'TEXAS', zip: '78734' },
  { street: '5678 North Lake Shore Drive', city: '555-123-4567', state: 'Illinois', zip: '610' },
  { street: '9123 West Flagler Street', city: '1233144', state: 'NotAState', zip: 'Miami' }
]
formatted_address_hashes = CrmFormatter.format_addresses(array_of_addresses)
```

Formatted Addresses:

```
formatted_address_hashes = [
  {
    address_status: 'formatted',
    full_addr: '1234 East Fair Boulevard, Austin, Texas, 78734',
    full_addr_f: '1234 E Fair Blvd, Austin, TX, 78734',
    street_f: '1234 E Fair Blvd',
    city_f: 'Austin',
    state_f: 'TX',
    zip_f: '78734'
  },
  {
    address_status: 'formatted',
    full_addr: '5678 North Lake Shore Drive, 555-123-4567, Illinois, 610',
    full_addr_f: '5678 N Lake Shore Dr, IL',
    street_f: '5678 N Lake Shore Dr',
    city_f: nil,
    state_f: 'IL',
    zip_f: nil
  },
  {
    address_status: 'formatted',
    full_addr: '9123 West Flagler Street, 1233144, NotAState, Miami',
    full_addr_f: '9123 W Flagler St',
    street_f: '9123 W Flagler St',
    city_f: nil,
    state_f: nil,
    zip_f: nil
  }
]
```

### II. Advanced Usage
Advanced usage has ability to parse a CSV file or pass large data sets.  It also leverages the Utf8Sanitizer gem to check for and remove any non-UTF8 characters and extra whitespace (double spaces, new line, new paragraph, carriage returns, etc.).  The results will include a detailed report including the line numbers of altered data, along with the before and after for comparison.  Then, it passes that data to the CrmFormatter gem's advanced usage to format all parts of the CRM data together (Address, Phone, Web)

Access advanced usage via `format_with_report(args)` method and pass a csv file_path or data hashes.

1. Parse and Format CSV via File Path (Must be absolute path to root and follow the syntax as below)

```
formatted_csv_results = CrmFormatter.format_with_report(file_path: './path/to/your/csv.csv')
```

Parsed & Formatted CSV Results:

```
formatted_csv_results = {
  stats:
  {
    total_rows: 2,
    header_row: 1,
    valid_rows: 1,
    error_rows: 0,
    defective_rows: 0,
    perfect_rows: 0,
    encoded_rows: 1,
    wchar_rows: 0
  },
  data:
  {
    valid_data:
    [
      {
        row_id: 1,
        act_name: 'Courtesy Ford',
        street: '1410 West Pine Street Hattiesburg',
        city: 'Wexford',
        state: 'MS',
        zip: '39401',
        full_addr: '1410 West Pine Street Hattiesburg, Wexford, MS, 39401',
        phone: '512-555-1212',
        url: 'http://www.courtesyfordsales.com',
        street_f: '1410 W Pine St Hattiesburg',
        city_f: 'Wexford',
        state_f: 'MS',
        zip_f: '39401',
        full_addr_f: '1410 W Pine St Hattiesburg, Wexford, MS, 39401',
        phone_f: '(512) 555-1212',
        url_f: 'http://www.courtesyfordsales.com',
        url_path: nil,
        web_neg: nil,
        address_status: 'formatted',
        phone_status: 'formatted',
        web_status: 'unchanged',
        utf_status: 'encoded'
      }
    ],
    encoded_data:
    [
      { row_id: 1,
        text: "http://www.courtesyfordsales.com,Courtesy Ford,__\xD5\xCB\xEB\x8F\xEB__\xD5\xCB\xEB\x8F\xEB____1410 West Pine Street Hattiesburg,Wexford,MS,39401,512-555-1212" }
    ],
    defective_data: [],
    error_data: []
    },
    file_path: './path/to/your/csv.csv'
  }
```

2. Format Data Hashes

```
data_hashes_array = [{ row_id: '1', url: 'abcacura.com/twitter', act_name: "Stanley Chevrolet Kaufman\x99_\xCC", street: '825 East Fair Street', city: 'Kaufman', state: 'Texas', zip: '75142', phone: "555-457-4391\r\n" }]

formatted_data_hash_results = CrmFormatter.format_with_report(data: data_hashes_array)
```

Formatted Data Hashes Results:

```
formatted_data_hash_results = { stats:
  {
    total_rows: '1',
    header_row: 1,
    valid_rows: 1,
    error_rows: 0,
    defective_rows: 0,
    perfect_rows: 0,
    encoded_rows: 1,
    wchar_rows: 1
  },
  data:
  {
    valid_data:
    [
      {
        row_id: '1',
        act_name: 'Stanley Chevrolet Kaufman',
        street: '825 East Fair Street',
        city: 'Kaufman',
        state: 'Texas',
        zip: '75142',
        full_addr: '825 East Fair Street, Kaufman, Texas, 75142',
        phone: '555-457-4391',
        url: 'abcacura.com/twitter',
        street_f: '825 E Fair St',
        city_f: 'Kaufman',
        state_f: 'TX',
        zip_f: '75142',
        full_addr_f: '825 E Fair St, Kaufman, TX, 75142',
        phone_f: '(555) 457-4391',
        url_f: 'http://www.abcacura.com',
        url_path: '/twitter',
        web_neg: nil,
        address_status: 'formatted',
        phone_status: 'formatted',
        web_status: 'formatted',
        utf_status: 'encoded, wchar'
      }
    ],
    encoded_data:
        [
          {
            row_id: '1',
            text: "1,abcacura.com/twitter,Stanley Chevrolet Kaufman\x99_\xCC,825 East Fair Street,Kaufman,Texas,75142,555-457-4391\r\n"
          }
        ],
    defective_data: [],
    error_data: []
  },
  file_path: nil
}
```

## Author

Adam J Booth  - [4rlm](https://github.com/4rlm)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/4rlm/crm_formatter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CrmFormatter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/4rlm/crm_formatter/blob/master/CODE_OF_CONDUCT.md).
