module Loverload
  class Block

    attr_reader :block

    def initialize(&block)
      @block = block.to_proc
    end

  end
end
