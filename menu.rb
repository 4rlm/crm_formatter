# frozen_string_literal: false

require_relative "lib/crm_formatter/address.rb"

address = CrmFormatter::Address.new

system "clear"
puts "Welcome!"

puts address.state
