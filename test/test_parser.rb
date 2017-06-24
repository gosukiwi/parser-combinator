require "minitest/autorun"
require "pry"
require_relative "../lib/parser"

def parser_for(input, &block)
  result = Parser.build(&block)
  result.call input
end

describe Parser do
  it "must parse one" do
    result = parser_for "abcdef" do
      rule(:one) { one "a" }
      start(:one)
    end
    assert_equal true, result
  end

  it "matches using satisfy"

  it "matches anyLetter" do
    parser = Parser.build do
      rule(:any) { anyLetter }
      start(:any)
    end

    assert_equal true, parser.call("abzx")
    assert_equal true, parser.call("ZNasd")
  end

  it "matches anyNumber" do
    parser = Parser.build do
      rule(:any) { anyNumber }
      start(:any)
    end

    assert_equal true, parser.call("12asd3")
    assert_equal true, parser.call("32asd")
  end

  it "matches many1" do
    result = parser_for "foo" do
      rule(:word) { many1 { anyLetter } }
      start(:word)
    end
    assert_equal true, result
  end

  it "matches many0" do
    parser = Parser.build do
      rule(:word) { many0 { anyLetter } }
      start(:word)
    end

    assert_equal true, parser.call("")
    assert_equal true, parser.call("abcde")
  end

  it "matches or" do
    parser = Parser.build do
      rule(:letter)         { many1 { anyLetter } }
      rule(:number)         { many0 { anyNumber } }
      rule(:letterOrNumber) { match first: rule(:letter), orElse: rule(:number) }
      start(:letterOrNumber)
    end

    assert_equal true, parser.call("n")
    assert_equal true, parser.call("6")
    assert_equal true, parser.call("")
  end

  #it "matches using seq" do
  #  parser = Parser.build do
  #    rule(:letter)         { many1 { anyLetter } }
  #    rule(:number)         { many0 { anyNumber } }
  #    rule(:letterOrNumber) { seq rule(:letter), rule(:number) { |letter, number| [letter, number] } }
  #    start(:letterOrNumber)
  #  end

  #  assert_equal [true, true], parser.call("w8")
  #end
end
