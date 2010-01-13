module Parby
  class ParseError < StandardError
    attr_accessor :id, :position, :message
    def initialize id, position, message=""
      @id, @position, @message = id, position, message
    end
  end

  class Parser
    attr_accessor :input, :position, :state

    def initialize input
      @input = input
      @position = 0
      @state = nil
    end

    def parse &block
      instance_eval &block if block_given?
    end

    def eof?
      @position == @input.length
    end

    def pop
      @position += 1
    end

    def push
      @position -= 1
    end

    def token
      fail :eof, "Unexpected EOF." if eof?
      pop
      @input[@position - 1]
    end

    def lookahead length = 1
      @input[@position..@position + (length - 1)]
    end

    def fail id, message
      raise ParseError.new id, @position, message
    end

    def unexpected wanted, got
      fail :unexpected, "Expected #{wanted}, got #{got}."
    end
  end
end
