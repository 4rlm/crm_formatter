require "crm_formatter/version"
require "crm_formatter/dictionary"
require 'crm_formatter/address'
require 'crm_formatter/web'
require 'crm_formatter/web_wrap'
require 'crm_formatter/phone'
require 'crm_formatter/tools'
require 'crm_formatter/parser'

require 'pry'

module CrmFormatter

  def self.run
    run_web_wrap
    # dicts
    # run_format_url
  end

  def self.run_web_wrap
    web_wrap = self::WebWrap
    web_wrap.wrap
  end

  def self.dicts
    dict = self::Dictionary
    msg = dict.dict_page
    binding.pry
    msg
  end

  # def self.run_format_url
  #   web = self::Web.new(get_args)
  #   urls = get_urls
  #
  #   formatted_url_hashes = urls.map do |url|
  #     url_hash = web.format_url(url)
  #   end
  #
  #
  #   puts formatted_url_hashes
  #   binding.pry
  # end


    # file_path = "./lib/crm_formatter/extensions.csv"
    # iana_list = CSV.read(file_path).flatten
    # matched_exts = iana_list & url_exts



  def self.get_args
    neg_urls = %w(approv avis budget collis eat enterprise facebook financ food google gourmet hertz hotel hyatt insur invest loan lube mobility motel motorola parts quick rent repair restaur rv ryder service softwar travel twitter webhost yellowpages yelp youtube)

    pos_urls = ["acura", "alfa romeo", "aston martin", "audi", "bmw", "bentley", "bugatti", "buick", "cdjr", "cadillac", "chevrolet", "chrysler", "dodge", "ferrari", "fiat", "ford", "gmc", "group", "group", "honda", "hummer", "hyundai", "infiniti", "isuzu", "jaguar", "jeep", "kia", "lamborghini", "lexus", "lincoln", "lotus", "mini", "maserati", "mazda", "mclaren", "mercedes-benz", "mitsubishi", "nissan", "porsche", "ram", "rolls-royce", "saab", "scion", "smart", "subaru", "suzuki", "toyota", "volkswagen", "volvo"]

    # neg_links = %w(: .biz .co .edu .gov .jpg .net // afri anounc book business buy bye call cash cheap click collis cont distrib download drop event face feature feed financ find fleet form gas generat graphic hello home hospi hour hours http info insta inventory item join login mail mailto mobile movie museu music news none offer part phone policy priva pump rate regist review schedul school service shop site test ticket tire tv twitter watch www yelp youth)

    # neg_hrefs = %w(? .com .jpg @ * afri after anounc apply approved blog book business buy call care career cash charit cheap check click collis commerc cont contrib deal distrib download employ event face feature feed financ find fleet form gas generat golf here holiday hospi hour info insta inventory join later light login mail mobile movie museu music news none now oil part pay phone policy priva pump quick quote rate regist review saving schedul service shop sign site speci ticket tire today transla travel truck tv twitter watch youth)

    neg_exts = %w(au ca edu es gov in ru uk us)
    oa_args = {neg_urls: neg_urls, pos_urls: pos_urls, neg_exts: neg_exts}
  end

  ##Rails C: StartCrm.run_webs
  def self.get_urls
    urls = %w(approvedautosales.org autosmartfinance.com leessummitautorepair.net melodytoyota.com northeastacura.com gemmazda.com)
    urls += %w(website.com website.business.site website website.fake website.fake.com website.com.fake)
  end






end
