module Parby
  class Parser
    def satisfy pred
      tok = token

      if pred.call tok
        tok
      else
        @position -= 1
        fail :unsatisfied, "Token #{tok} failed to satisfy predicate."
      end
    end

    def string str
      str.each_char do |c|
        tok = token
        unexpected c, tok if tok != c
      end

      str
    end

    def try
      pos = @position

      begin
        result = yield
      rescue ParseError => err
        @position = pos
        return :fail
      end

      result
    end

    def choice *parsers
      before = @position

      parsers.each do |p|
        begin
          res = p.call
          return res unless res == :fail
        rescue ParseError
          fail :consumed, "Choice failed and consumed input." if @position != before
        end
      end

      fail :choice, "No choices parsed successfully."
    end

    def many
      results = []

      loop do
        begin
          results << yield
        rescue ParseError
          break
        end
      end if block_given?

      results
    end
  end
end
