require 'lib/parby/core'
require 'lib/parby/combinators'

class String
  def parse &block
    parser = Parby::Parser.new self
    parser.parse &block
  end
end
