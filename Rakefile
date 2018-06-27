# frozen_string_literal: false

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'crm_formatter'

RSpec::Core::RakeTask.new(:spec)
task default: :spec
task test: :spec

task :console do
  require 'irb'
  require 'irb/completion'
  require 'crm_formatter'
  require 'active_support/all'
  ARGV.clear

  # formatted_data = format_with_report
  # formatted_phones = format_phones
  formatted_urls = format_urls
  # formatted_addresses = format_addresses
  IRB.start
end

def format_with_report
  data = [{ row_id: '1', url: 'abcacura.com/twitter', act_name: "Stanley Chevrolet Kaufman\x99_\xCC", street: '825 East Fair Street', city: 'Kaufman', state: 'Texas', zip: '75142', phone: "555-457-4391\r\n" }]

  file_path = './lib/crm_formatter/csv/seed.csv'

  # args = {data: data}
  args = { file_path: file_path }
  formatted_data = CrmFormatter.format_with_report(args)
end

def format_addresses
  array_of_addresses = [
    { street: '1234 EAST FAIR BOULEVARD', city: 'AUSTIN', state: 'TEXAS', zip: '78734' },
    { street: '5678 North Lake Shore Drive', city: '555-123-4567', state: 'Illinois', zip: '610' },
    { street: '9123 West Flagler Street', city: '1233144', state: 'NotAState', zip: 'Miami' }
  ]
  formatted_addresses = CrmFormatter.format_addresses(array_of_addresses)
end

def format_phones
  array_of_phones = %w[
    555-457-4391 555-888-4391
    555-457-4334
    555-555 555.555.1234
    not_a_number
  ]
  formatted_phones = CrmFormatter.format_phones(array_of_phones)
end

def format_urls
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

  array_of_urls = %w[sample01.com/staff www.sample02.net.com http://www.sample3.net www.sample04.net/contact_us http://sample05.net www.sample06.sofake www.sample07.com.sofake example08.not.real www.sample09.net/staff/management www.www.sample10.com]
  formatted_urls = CrmFormatter.format_urls(array_of_urls)
end
