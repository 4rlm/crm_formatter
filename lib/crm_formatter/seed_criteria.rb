# SeedCriteria.new.all_criteria

module CrmFormatter
  class SeedCriteria

    def all_criteria
      {neg_urls: neg_urls, pos_urls: pos_urls, neg_exts: neg_exts}
    end

    def seed_neg_urls
      %w(approv avis budget collis eat enterprise facebook financ food google gourmet hertz hotel hyatt insur invest loan lube mobility motel motorola parts quick rent repair restaur rv ryder service softwar travel twitter webhost yellowpages yelp youtube)
    end

    def seed_pos_urls
      ["acura", "alfa romeo", "aston martin", "audi", "bmw", "bentley", "bugatti", "buick", "cdjr", "cadillac", "chevrolet", "chrysler", "dodge", "ferrari", "fiat", "ford", "gmc", "group", "group", "honda", "hummer", "hyundai", "infiniti", "isuzu", "jaguar", "jeep", "kia", "lamborghini", "lexus", "lincoln", "lotus", "mini", "maserati", "mazda", "mclaren", "mercedes-benz", "mitsubishi", "nissan", "porsche", "ram", "rolls-royce", "saab", "scion", "smart", "subaru", "suzuki", "toyota", "volkswagen", "volvo"]
    end

    def seed_neg_links
      %w(: .biz .co .edu .gov .jpg .net // afri anounc book business buy bye call cash cheap click collis cont distrib download drop event face feature feed financ find fleet form gas generat graphic hello home hospi hour hours http info insta inventory item join login mail mailto mobile movie museu music news none offer part phone policy priva pump rate regist review schedul school service shop site test ticket tire tv twitter watch www yelp youth)
    end

    def seed_neg_hrefs
      neg_hrefs = %w(? .com .jpg @ * afri after anounc apply approved blog book business buy call care career cash charit cheap check click collis commerc cont contrib deal distrib download employ event face feature feed financ find fleet form gas generat golf here holiday hospi hour info insta inventory join later light login mail mobile movie museu music news none now oil part pay phone policy priva pump quick quote rate regist review saving schedul service shop sign site speci ticket tire today transla travel truck tv twitter watch youth)
    end

    def seed_neg_exts
       %w(au ca edu es gov in ru uk us)
    end

    # ##Rails C: StartCrm.run_webs
    # def self.get_urls
    #   urls = %w(approvedautosales.org autosmartfinance.com leessummitautorepair.net melodytoyota.com northeastacura.com gemmazda.com)
    #   urls += %w(website.com website.business.site website website.fake website.fake.com website.com.fake)
    # end

  end
  #code
end
