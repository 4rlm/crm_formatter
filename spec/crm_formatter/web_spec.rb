# rspec spec/crm_formatter/web_spec.rb
require 'spec_helper'

###########################
## Note: Methods below require 'criteria' in args. Tests unwritten.

# consolidate_neg_pos
# run_scrub
# extract_path
# strip_down_url
# remove_invalid_links
# remove_invalid_hrefs
# remove_slashes
###########################

describe 'Web' do
  # before { utf_obj.headers = headers }
  let(:web_obj) { CrmFormatter::Web.new }
  let(:url_str_in) { 'sample1.com' }
  let(:url_hsh_out) do
    {
      :web_status=>"formatted",
      :url_path=>"sample1.com",
      :url_f=>"http://www.sample1.com", :web_neg=>nil,
      :web_pos=>nil
    }
  end

  describe '#format_url' do
    it 'formats url' do
      expect(web_obj.format_url(url_str_in)).to eql(url_hsh_out)
    end
  end

  describe '#check_web_status' do
    let(:url_hsh_in) do
      {
        :web_status=>false,
        :url_path=>"sample1.com",
        :url_f=>"http://www.sample1.com",
        :web_neg=>nil,
        :web_pos=>nil
      }
    end

    it 'compares orig and formatted url' do
      expect(web_obj.check_web_status(url_hsh_in)).to eql(url_hsh_out)
    end
  end

  describe '#prep_for_uri' do
    let(:url_hsh_out) do
      {
        :url_hash=>
        {
          :web_status=>false,
          :url_path=>"sample1.com",
          :url_f=>nil,
          :web_neg=>[],
          :web_pos=>[]
        },
        :url=>"sample1.com"
      }
    end

    it "prepares url for uri" do
      expect(web_obj.prep_for_uri(url_str_in)).to eql(url_hsh_out)
    end
  end


  describe '#normalize_url' do
    let(:url_str_out) { 'http://www.sample1.com' }

    it 'normalizes url' do
      expect(web_obj.normalize_url(url_str_in)).to eql(url_str_out)
    end
  end

  describe '#validate_extension' do
    let(:url) { 'http://www.sample1.com' }

    let(:url_hash_in) do
      {
        :web_status=>false,
        :url_path=>"sample1.com",
        :url_f=>nil,
        :web_neg=>[],
        :web_pos=>[]
      }
    end

    let(:url_hash_out) do
      {
        :url_hash=>{:web_status=>false,
        :url_path=>"sample1.com",
        :url_f=>nil,
        :web_neg=>[],
        :web_pos=>[]},
        :url=>"http://www.sample1.com"
      }
    end

    it "validates extension" do
      expect(web_obj.validate_extension(url_hash_in, url)).to eql(url_hash_out)
    end
  end

end
