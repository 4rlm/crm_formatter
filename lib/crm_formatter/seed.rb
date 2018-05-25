require 'csv'

module CrmFormatter
  class Seed
    def initialize(args={})
      # @pollute_seeds = args.fetch(:pollute_seeds, false)
      # @seed_hashes = args.fetch(:seed_hashes, false)
      # @seed_csv = args.fetch(:seed_csv, false)
    end

    def pollute_seeds(text)
      list = ['h∑', 'lÔ', "\x92", "\x98", "\x99", "\xC0", "\xC1", "\xC2", "\xCC", "\xDD", "\xE5", "\xF8"]
      index = text.length / 2
      var = "#{list.sample}_#{list.sample}"
      text.insert(index, var)
      text.insert(-1, "\r\n")
      text
    end

    def grab_seed_file_path
      # "./lib/crm_formatter/csv/seeds_clean.csv"
      # "./lib/crm_formatter/csv/seeds_dirty.csv"
      # "./lib/crm_formatter/csv/seeds_mega.csv"
      # "./lib/crm_formatter/csv/seeds_mini.csv"
      # "./lib/crm_formatter/csv/seeds_mini_10.csv"
      './lib/crm_formatter/csv/seeds_mini_2_bug.csv'
    end

    ### Sample Hashes for validate_data
    def grab_seed_hashes
      [{ row_id: 1,
         url: 'stanleykaufman.com',
         act_name: 'Stanley Chevrolet Kaufman',
         street: '825 E Fair St',
         city: 'Kaufman',
         state: 'TX',
         zip: '75142',
         phone: '(888) 457-4391' },
       { row_id: 2,
         url: 'leepartyka',
         act_name: 'Lee Partyka Chevrolet Mazda Isuzu Truck',
         street: '200 Skiff St',
         city: 'Hamden',
         state: 'CT',
         zip: '6518',
         phone: '(203) 288-7761' },
       { row_id: 3,
         url: 'burienhonda.fake.not.net.com',
         act_name: 'Honda of Burien 15026 1st Avenue South, Burien, WA 98148',
         street: '15026 1st Avenue South',
         city: 'Burien',
         state: 'WA',
         zip: '98148',
         phone: '(206) 246-9700' },
       { row_id: 4,
         url: 'cortlandchryslerdodgejeep.com',
         act_name: 'Cortland Chrysler Dodge Jeep RAM',
         street: '3878 West Rd',
         city: 'Cortland',
         state: 'NY',
         zip: '13045',
         phone: '(877) 279-3113' },
       { row_id: 5,
         url: 'imperialmotors.net',
         act_name: 'Imperial Motors',
         street: '4839 Virginia Beach Blvd',
         city: 'Virginia Beach',
         state: 'VA',
         zip: '23462',
         phone: '(757) 490-3651' }]
    end



    def grab_seed_web_criteria
      pos_urls, neg_urls, neg_links, neg_hrefs, neg_exts = [], [], [], [], []

      neg_urls = %w[approv avis budget collis eat enterprise facebook financ food google gourmet hertz hotel hyatt insur invest loan lube mobility motel motorola parts quick rent repair restaur rv ryder service softwar travel twitter webhost yellowpages yelp youtube]

      pos_urls = ['acura', 'alfa romeo', 'aston martin', 'audi', 'bmw', 'bentley', 'bugatti', 'buick', 'cdjr', 'cadillac', 'chevrolet', 'chrysler', 'dodge', 'ferrari', 'fiat', 'ford', 'gmc', 'group', 'group', 'honda', 'hummer', 'hyundai', 'infiniti', 'isuzu', 'jaguar', 'jeep', 'kia', 'lamborghini', 'lexus', 'lincoln', 'lotus', 'mini', 'maserati', 'mazda', 'mclaren', 'mercedes-benz', 'mitsubishi', 'nissan', 'porsche', 'ram', 'rolls-royce', 'saab', 'scion', 'smart', 'subaru', 'suzuki', 'toyota', 'volkswagen', 'volvo']

      # neg_links = %w(: .biz .co .edu .gov .jpg .net // afri anounc book business buy bye call cash cheap click collis cont distrib download drop event face feature feed financ find fleet form gas generat graphic hello home hospi hour hours http info insta inventory item join login mail mailto mobile movie museu music news none offer part phone policy priva pump rate regist review schedul school service shop site test ticket tire tv twitter watch www yelp youth)

      # neg_hrefs = %w(? .com .jpg @ * afri after anounc apply approved blog book business buy call care career cash charit cheap check click collis commerc cont contrib deal distrib download employ event face feature feed financ find fleet form gas generat golf here holiday hospi hour info insta inventory join later light login mail mobile movie museu music news none now oil part pay phone policy priva pump quick quote rate regist review saving schedul service shop sign site speci ticket tire today transla travel truck tv twitter watch youth)

      neg_exts = %w[au ca edu es gov in ru uk us]

      oa_args = { pos_urls: pos_urls, neg_urls: neg_urls, neg_links: neg_links, neg_hrefs: neg_hrefs, neg_exts: neg_exts }
      oa_args.compact
    end





  end
end
