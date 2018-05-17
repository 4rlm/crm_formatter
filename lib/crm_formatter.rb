require "crm_formatter/version"
require "crm_formatter/dictionary"
require 'crm_formatter/address'
require 'crm_formatter/web'
require 'crm_formatter/phone'
require 'crm_formatter/tools'
require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'


module CrmFormatter

  def self.generate_title
    title_array = title.split
  end

  def self.hello
    "Welcome to crm_formatter ...."
  end

end
