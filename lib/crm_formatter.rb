# frozen_string_literal: false

require 'crm_formatter/version'
require 'crm_formatter/address'
require 'crm_formatter/web'
require 'crm_formatter/wrap'
require 'crm_formatter/phone'
require 'crm_formatter/tools'
require 'pry'
require 'utf8_sanitizer'

module CrmFormatter

  def self.format(args={})
    formatted_data = self::Wrap.new.run(args)
    binding.pry
    formatted_data
  end

end
