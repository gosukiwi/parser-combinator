require "minitest/autorun"
require "pry"
require_relative "../lib/parser"

def assert_parses(parser, with:, remaining:)
  result = parser.call(with)
  assert_equal true,      result.success
  assert_equal remaining, result.remaining
end

describe Parser do
  it "must parse one" do
    parser = Parser.build do
      rule(:one) { one "a" }
      start(:one)
    end

    assert_parses parser, with: "abc", remaining: "bc"
  end

  it "matches satisfy"

  it "matches anyOf"

  it "matches anyLetter" do
    parser = Parser.build do
      rule(:any) { anyLetter }
      start(:any)
    end

    assert_parses parser, with: "abzx", remaining: "bzx"
    assert_parses parser, with: "Znasd", remaining: "nasd"
  end

  it "matches anyNumber" do
    parser = Parser.build do
      rule(:any) { anyNumber }
      start(:any)
    end

    assert_parses parser, with: "12asd3", remaining: "2asd3"
    assert_parses parser, with: "32asd", remaining: "2asd"
  end

  it "matches many1" do
    parser = Parser.build do
      rule(:word) { many1 { anyLetter } }
      start(:word)
    end

    assert_parses parser, with: "asd123", remaining: "123"
  end

  it "matches many0" do
    parser = Parser.build do
      rule(:word) { many0 { anyLetter } }
      start(:word)
    end

    assert_parses parser, with: "",      remaining: ""
    assert_parses parser, with: "abcde", remaining: ""
  end

  it "matches or" do
    parser = Parser.build do
      rule(:letter)         { many1 { anyLetter } }
      rule(:number)         { many0 { anyNumber } }
      rule(:letterOrNumber) { match first: rule(:letter), orElse: rule(:number) }
      start(:letterOrNumber)
    end

    assert_parses parser, with: "n", remaining: ""
    assert_parses parser, with: "6", remaining: ""
    assert_parses parser, with: "",  remaining: ""
  end

  it "matches using seq" do
    parser = Parser.build do
      rule(:letter)         { many1 { anyLetter } }
      rule(:number)         { many0 { anyNumber } }
      rule(:letterOrNumber) { seq rule(:letter), rule(:number), lambda { |letter, number| [letter, number] } }
      start(:letterOrNumber)
    end

    assert_equal ["w", "8"], parser.call("w8")
  end
end
