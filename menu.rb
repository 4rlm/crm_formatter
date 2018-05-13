require_relative "lib/crm_formatter/address.rb"

address = CRMFormatter::Address.new

system "clear"
puts "Welcome!"

puts address.state
