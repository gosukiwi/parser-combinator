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
end
