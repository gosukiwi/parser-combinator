require "minitest/autorun"
require "pry"
require_relative "spec_helpers"

describe Grammar do
  describe "Built-in combinators" do
    it "matches nothing" do
      parser = Grammar.build do
        rule(:foo) { nothing }
        start(:foo)
      end

      assert_parses       parser, with: "",    remaining: ""
      assert_doesnt_parse parser, with: "asd", remaining: "asd"
    end

    it "must parse one" do
      parser = Grammar.build do
        rule(:one) { one "a" }
        start(:one)
      end

      assert_parses parser, with: "abc", remaining: "bc"
    end
  end

  it "can make rules by hand" do
    parser = Grammar.build do
      rule(:foo) { Parser.new { |input| input == "foo" ? ParserResult.ok(matched: "foo", remaining: "") : ParserResult.fail(input) } }
      start(:foo)
    end

    assert_parses parser, with: "foo", remaining: ""
  end

  it "matching rules by hand is the same as satisfy" do
    parser = Grammar.build do
      rule(:foo) { satisfy { |input| input == "foo" ? ParserResult.ok(matched: "foo", remaining: "") : ParserResult.fail(input) } }
      start(:foo)
    end

    assert_parses parser, with: "foo", remaining: ""
  end

  it "matches anyOf"

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

  describe "logical OR" do
    it "works with a single branch" do
      parser = Grammar.build do
        rule(:letter)         { many1 { anyLetter } }
        rule(:number)         { many0 { anyNumber } }
        rule(:letterOrNumber) { rule(:letter) | rule(:number) }
        start(:letterOrNumber)
      end

      assert_parses parser, with: "n", remaining: ""
      assert_parses parser, with: "6", remaining: ""
      assert_parses parser, with: "",  remaining: ""
    end

    it "works with multiple branches" do
      parser = Grammar.build do
        rule(:letter)         { many1 { anyLetter } }
        rule(:number)         { many1 { anyNumber } }
        rule(:letterOrNumber) { rule(:letter) | rule(:number) | nothing }
        start(:letterOrNumber)
      end

      assert_parses parser, with: "n", remaining: ""
      assert_parses parser, with: "6", remaining: ""
      assert_parses parser, with: "",  remaining: ""
    end
  end

  describe "logical AND" do
    it "works with a single branch" do
      parser = Grammar.build do
        rule(:letter)          { many1 { anyLetter } }
        rule(:number)          { many0 { anyNumber } }
        rule(:letterAndNumber) { rule(:letter) >> rule(:number) }
        start(:letterAndNumber)
      end

      assert_parses parser, with: "foo123", remaining: ""
    end

    it "works with multiple branches" do
      parser = Grammar.build do
        rule(:letter) { many1 { anyLetter } }
        rule(:number) { many0 { anyNumber } }
        rule(:foo)    { rule(:letter) >> rule(:number) >> rule(:letter) }
        start(:foo)
      end

      assert_parses       parser, with: "foo123asd", remaining: ""
      assert_doesnt_parse parser, with: "foo123",    remaining: "foo123"
    end

    it "works with rules and satisfies" do
      parser = Grammar.build do
        rule(:letter)          { many1 { anyLetter } }
        rule(:letterAndNumber) { rule(:letter) >> many0 { anyNumber } }
        start(:letterAndNumber)
      end

      assert_parses       parser, with: "foo123", remaining: ""
      assert_parses       parser, with: "foo",    remaining: ""
      assert_doesnt_parse parser, with: "123a",   remaining: "123a"
    end
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
end
