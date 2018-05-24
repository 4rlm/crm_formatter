# frozen_string_literal: true

require 'crm_formatter/version'
require 'crm_formatter/dictionary'
require 'crm_formatter/address'
require 'crm_formatter/web'
require 'crm_formatter/wrap'
require 'crm_formatter/phone'
require 'crm_formatter/tools'
require 'crm_formatter/utf'
require 'crm_formatter/seed'

require 'pry'

module CrmFormatter

  def self.run
    run_web_wrap
    # dicts
    # format_urls
  end

  def self.run_web_wrap
    wrap = self::Wrap.new
    wrap.wrap ## returns formatted urls.
  end

  def self.dicts
    dict = self::Dictionary
    msg = dict.dict_page
    binding.pry
    msg
  end
end
