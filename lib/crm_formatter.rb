class CRMFormatter
  def self.hi(language)
    translator = Translator.new(language)
    translator.hi
  end
end

require 'crm_formatter/translator'
