module Parby
  class ParseError < StandardError
    attr_accessor :message, :position, :info
    def initialize message, position, info=""
      @message, @position, @info = message, position, info
    end

    def to_s
      "parse error: #{message}: #{info}"
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

    def fail message, info
      raise ParseError.new message, @position, info
    end

    def unexpected got, wanted
      fail :unexpected, "Unexpected `#{got}' (wanted `#{wanted}')."
    end
  end
end
