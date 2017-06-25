require "minitest/autorun"
require "pry"
require_relative "spec_helpers"

describe Grammar do
  describe "Built-in combinators" do
    it "matches eof" do
      parser = Grammar.build do
        rule(:foo) { eof }
        start(:foo)
      end

      assert_parses parser, with: "",    remaining: ""
      assert_parses parser, with: "asd", remaining: "asd", should_fail: true
    end

    it "matches empty" do
      parser = Grammar.build do
        rule(:foo) { empty }
        start(:foo)
      end

      assert_parses parser, with: "asd", remaining: "asd"
      assert_parses parser, with: "",    remaining: ""
    end

    it "matches whitespace" do
      parser = Grammar.build do
        rule(:foo) { whitespace }
        start(:foo)
      end

      assert_parses parser, with: "  asd", remaining: "asd"
      assert_parses parser, with: "",    remaining: ""
    end

    it "must parse one" do
      parser = Grammar.build do
        rule(:one) { one "a" }
        start(:one)
      end

      assert_parses parser, with: "abc", remaining: "bc"
    end

    it "must parse str" do
      parser = Grammar.build do
        rule(:foo) { str "foo" }
        start(:foo)
      end

      assert_parses parser, with: "foo",    remaining: ""
      assert_parses parser, with: "foobar", remaining: "bar"
      assert_parses parser, with: "fobar",  remaining: "fobar", should_fail: true
    end
  end

  it "can make rules by hand" do
    parser = Grammar.build do
      rule(:foo) { Parser.new { |input| input == "foo" ? ok(matched: "foo", remaining: "") : fail(input) } }
      start(:foo)
    end

    assert_parses parser, with: "foo", remaining: ""
  end

  it "matching rules by hand is the same as satisfy" do
    parser = Grammar.build do
      rule(:foo) { satisfy { |input| input == "foo" ? ok(matched: "foo", remaining: "") : fail(input) } }
      start(:foo)
    end

    assert_parses parser, with: "foo", remaining: ""
  end

  it "matches anyLetter" do
    parser = Grammar.build do
      rule(:any) { anyLetter }
      start(:any)
    end

    assert_parses parser, with: "abzx", remaining: "bzx"
    assert_parses parser, with: "Znasd", remaining: "nasd"
  end

  it "matches anyNumber" do
    parser = Grammar.build do
      rule(:any) { anyNumber }
      start(:any)
    end

    assert_parses parser, with: "12asd3", remaining: "2asd3"
    assert_parses parser, with: "32asd", remaining: "2asd"
  end

  it "matches many1" do
    parser = Grammar.build do
      rule(:word) { many1 { anyLetter } }
      start(:word)
    end

    assert_parses parser, with: "asd123", remaining: "123"
  end

  it "matches many0" do
    parser = Grammar.build do
      rule(:word) { many0 { anyLetter } }
      start(:word)
    end

    assert_parses parser, with: "",      remaining: ""
    assert_parses parser, with: "abcde", remaining: ""
  end

  it "matches using seq" do
    parser = Grammar.build do
      rule(:letter)         { many1 { anyLetter } }
      rule(:number)         { many0 { anyNumber } }
      rule(:letterOrNumber) { seq rule(:letter), rule(:number), lambda { |letter, number| [letter, number] } }
      start(:letterOrNumber)
    end

    assert_equal ["w", "8"], parser.run("w8")

    parser = Grammar.build do
      rule(:letter)         { many1 { anyLetter } }
      rule(:letterOrNumber) { seq rule(:letter), anyNumber, lambda { |letter, number| [letter, number] } }
      start(:letterOrNumber)
    end

    assert_equal ["w", "8"], parser.run("w8")
  end

  it "uses regex" do
    parser = Grammar.build do
      rule(:foo) { regex /foo/ }
      start(:foo)
    end

    assert_parses parser, with: "foo", remaining: ""
  end

  it "matches between" do
    parser = Grammar.build do
      rule(:quote) { one '"' }
      rule(:foo)   { match (many1 { anyLetter }), between: [rule(:quote), rule(:quote)] }
    end

    assert_parses parser, with: '"hi"', remaining: ''
  end

  it "matches anyChar" do
    parser = Grammar.build do
      rule(:foo) { anyChar ['a', 'b'] }
      start(:foo)
    end

    assert_parses parser, with: "asd", remaining: "sd"
    assert_parses parser, with: "bsd", remaining: "sd"
    assert_parses parser, with: "c",   remaining: "c", should_fail: true
  end

  it "matches anyCharBut" do
    parser = Grammar.build do
      rule(:foo) { anyCharBut ['a', 'b'] }
      start(:foo)
    end

    assert_parses parser, with: "c", remaining: ""
    assert_parses parser, with: "d", remaining: ""
    assert_parses parser, with: "a", remaining: "a", should_fail: true
    assert_parses parser, with: "b", remaining: "b", should_fail: true
  end

  it "matches exactly n times" do
    parser = Grammar.build do
      rule(:foo) { exactly(4) { anyLetter } }
      start(:foo)
    end

    assert_parses parser, with: "abcde", remaining: "e"
    assert_parses parser, with: "abcd",  remaining: ""
    assert_parses parser, with: "a",     remaining: "a",  should_fail: true
    assert_parses parser, with: "abc",   remaining: "abc", should_fail: true
  end
end
