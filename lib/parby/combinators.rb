module Parby
  class Parser
    def satisfy pred
      return token if pred.call lookahead

      fail :unsatisfied, "Token `#{lookahead}' failed to satisfy predicate."
    end

    def string str
      str.each_char do |c|
        begin
          satisfy (-> tok { tok == c })
        rescue ParseError => e
          unexpected lookahead, c if e.message == :unsatisfied
          raise e
        end
      end

      str
    end

    def try
      pos = @position

      begin
        result = yield
      rescue ParseError
        result = :fail
        @position = pos
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
