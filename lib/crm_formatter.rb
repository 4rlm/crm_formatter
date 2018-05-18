require "crm_formatter/version"
require "crm_formatter/dictionary"
require 'crm_formatter/address'
require 'crm_formatter/web'
require 'crm_formatter/web_wrap'
require 'crm_formatter/phone'
require 'crm_formatter/tools'
require 'crm_formatter/utf'

require 'pry'

module CrmFormatter

  def self.run
    run_web_wrap
    # dicts
    # format_urls
  end

  def self.run_web_wrap
    web_wrap = self::WebWrap.new
    urls = web_wrap.wrap
    binding.pry if urls.any?
    urls
  end

  def self.dicts
    dict = self::Dictionary
    msg = dict.dict_page
    binding.pry
    msg
  end






end
