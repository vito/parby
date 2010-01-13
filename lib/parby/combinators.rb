module Parby
  class Parser
    def satisfy pred
      tok = token

      return tok if pred.call tok

      @position -= 1
      fail :unsatisfied, "Token #{tok} failed to satisfy predicate."
    end

    def string str
      str.each_char do |c|
        satisfy (-> tok { tok == c })
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
