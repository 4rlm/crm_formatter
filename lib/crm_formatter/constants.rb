module CRMFormatter
  module Constants

    def self.constant_mapper
      @constant_mapper ||= instantiate_constant_mapper
    end

    def self.instantiate_constant_mapper
      SHARED_ARGS = {}
      WOW = 'Exciting!'
    end

    # CRMFormatter::Constants::SHARED_ARGS

  end
end
