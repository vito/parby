require 'lib/parby/combinators'

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

    def run &block
      instance_eval &block if block_given?
    end

    def unexpected wanted, got
      fail :unexpected, "Expected #{wanted}, got #{got}."
    end

    def eof?
      @position == @input.length
    end

    def token
      fail :eof, "Unexpected EOF." if eof?
      @position += 1
      @input[@position - 1]
    end

    def fail id, message
      raise ParseError.new id, @position, message
    end
  end
end

class String
  def parse &block
    parser = Parby::Parser.new self
    parser.run &block
  end
end
