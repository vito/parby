require 'test/unit'
require 'lib/parby'

class ParbyTest < Test::Unit::TestCase
  def test_basic_token
    char = "abc".parse do
      token
    end

    assert_equal char, "a"
  end

  def test_many_token
    chars = "abc".parse do
      many { token }
    end

    assert_equal chars.join, "abc"
  end

  def test_sequence
    chars = "(abc)".parse do
      string "("
      chars = many { satisfy (-> c { c =~ /[a-z]/ }) }
      string ")"
      chars
    end

    assert_equal chars.join, "abc"
  end

  def test_try
    target = Parby::Parser.new "foo"

    failure = target.parse { try { string "fou" } }
    assert_nil failure
    assert_equal target.position, 0

    success = target.parse { try { string "foo" } }
    assert_equal success, "foo"
    assert_equal target.position, 3
  end
end
