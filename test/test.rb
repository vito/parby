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
    assert_equal :fail, failure
    assert_equal target.position, 0

    success = target.parse { try { string "foo" } }
    assert_equal success, "foo"
    assert_equal target.position, 3
  end

  def test_choice
    assert_raise Parby::ParseError, do
      "foo".parse do
        choice ->{ string "foa" },
               ->{ string "foo" }
      end
    end

    assert_nothing_raised do
      match = "foo".parse do
        choice ->{ try { string "foa" } },
               ->{ string "foo" }
      end

      assert_equal match, "foo"

      matches = "foobarfoobarbarfoo".parse do
        many do
          choice ->{ string "foo" },
                 ->{ string "bar" }
        end
      end

      assert_equal matches, ["foo", "bar", "foo", "bar", "bar", "foo"]
    end
  end
end
