
# CRM Wrap
#### Efficiently Reformat, Normalize, and Scrub CRM Contact Data, such as Addresses, Phones and URLs.

CRM Wrap is perfect for curating high-volume enterprise-scale web scraping, and integrates well with Nokogiri, Mechanize, and asynchronous jobs via Delayed_job or SideKick, to name a few.  Web Scraping and Harvesting often gathers a lot of junk to sift through; presenting unexpected edge cases around each corner.  CRM Wrap has been developed and refined during the past few years to focus on improving that task.

It's also perfect for processing API data, Web Forms, and routine DB normalizing and scrubbing processes.  Not only does it reformat Address, Phone, and Web data, it can also accept lists to scrub against, then providing detailed reports about how each piece of data compares with your criteria lists.

## Getting Started
CRM Wrap is compatible with Rails 4.2 and 5.0, 5.1 and 5.2 on Ruby 2.2 and later.

In your Gemfile add:
```
gem 'crm_formatter'
```
Or to install locally:
```
gem install crm_formatter
```
## Usage


### I. Basic Usage

1. Format Array of Phone Numbers:
```
array_of_phones = %w[
  555-457-4391 555-888-4391
  555-457-4334
  555-555 555.555.1234
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

2. Format Array of URLs:
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

3. Format Array of Addresses (each as a hash):
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

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
