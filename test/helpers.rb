module Spec::Matchers
  class ResultIn
    def initialize match
      @wanted = { result: match,
                  position: nil }
    end

    def matches? got
      @got = got

      return @wanted == @got unless @wanted[:position].nil?

      @wanted[:result] == @got[:result]
    end

    def failure_message
      "expected #{@wanted.inspect} but got #{@got.inspect}"
    end

    def position position
      @wanted[:position] = position
      self
    end

    alias :negative_failure_message :failure_message
  end

  def result_in want
    ResultIn.new want
  end
end

def parse target, &block
  target = Parby::Parser.new target unless target.is_a? Parby::Parser

  { result: (target.parse &block),
    position: target.position }
end
