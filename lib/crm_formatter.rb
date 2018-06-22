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

  def self.run_wrap
    wrap = self::Wrap.new
    wrap.run_wrap ## returns formatted urls.
  end

end
