class CRMFormatter
  def self.hi(language)
    translator = Translator.new(language)
    translator.hi
  end

  def self.bye(target)
    "Good bye. See ya, #{target}"
  end
end

require 'crm_formatter/translator'
