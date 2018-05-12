require 'test/unit'
require 'crm_formatter'

class CRMFormatterTest < Test::Unit::TestCase
  def test_english_hello
    assert_equal "hello world", CRMFormatter.hi("english")
  end

  def test_any_hello
    assert_equal "hello world", CRMFormatter.hi("ruby")
  end

  def test_spanish_hello
    assert_equal "crm_formatter mundo", CRMFormatter.hi("spanish")
  end
end
