require 'lib/parby'
require 'test/helpers'

describe Parby::Parser, "#token" do
  it "returns a single token" do
    "abc".parse { token }.should == "a"
  end

  it "raises a ParseError at EOF" do
    lambda {
      "".parse { token }
    }.should raise_exception(Parby::ParseError, :eof)
  end
end

describe Parby::Parser, "#satisfy" do
  it "returns a token that satifies a predicate" do
    parse "123" do
        satisfy (-> c { c =~ /[0-9]/ })
    end.should result_in("1").position(1)
  end

  it "raises a ParseError if token does not satisfy predicate." do
    lambda {
      "1".parse {
        satisfy (-> c { c =~ /[a-z]/ })
      }
    }.should raise_exception(Parby::ParseError, :unsatisfied)
  end
end

describe Parby::Parser, "#many" do
  it "continues until EOF" do
    parse "abc" do
      many { token }
    end.should result_in(["a", "b", "c"]).position(3)
  end

  it "continues until ParseError" do
    parse "abc123" do
      many { satisfy (-> c { c =~ /[a-z]/ }) }
    end.should result_in(["a", "b", "c"]).position(3)
  end
end

describe Parby::Parser, "#string" do
  it "parses a sequence of characters and returns the string if successful" do
    parse "foobar" do
      string "foo"
    end.should result_in("foo").position(3)
  end

  it "consumes input on failure" do
    target = Parby::Parser.new "foobar"

    lambda {
      lambda {
        target.parse {
          string "foa"
        }
      }.should raise_exception(Parby::ParseError, :unexpected)
    }.should change(target, :position).from(0).to(2)
  end
end

describe Parby::Parser, "#try" do
  it "resets position on failure" do
    parse "foobarbaz" do
      try { string "foa" }
    end.should result_in(:fail).position(0)
  end

  it "catches exceptions" do
    lambda {
      "foobarbaz".parse { try { string "foa" } }
    }.should_not raise_exception(Parby::ParseError, :unexpected)
  end

  it "returns parse result and updates position on success" do
    parse "foobarbaz" do
      try { string "foo" }
    end.should result_in("foo").position(3)
  end
end

describe Parby::Parser, "#choice" do
  it "returns result of first successful parse" do
    parse "foo" do
      choice ->{ try { string "foa" } },
             ->{ string "foo" }
    end.should result_in("foo").position(3)
  end

  it "fails if a branch fails and consumes input" do
    lambda {
      "foo".parse {
        choice ->{ string "foa" },
               ->{ string "foo" }
      }
    }.should raise_exception(Parby::ParseError, :consumed)
  end
end
