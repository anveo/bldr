
module Bldr

  class Engine
    attr_reader :template, :options, :result

    def initialize(template, options = {})
      @template, @options = template, options
      @result   = {}
    end

  end

end
