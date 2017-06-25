require "minitest/autorun"
require "pry"
require_relative "spec_helpers"

describe Grammar do
  describe "|" do
    it "works with a single branch" do
      parser = Grammar.build do
        rule(:letter)         { many1 { anyLetter } }
        rule(:number)         { many0 { anyNumber } }
        rule(:letterOrNumber) { rule(:letter) | rule(:number) }
        start(:letterOrNumber)
      end

      assert_parses parser, with: "n", remaining: "", matched: "n"
      assert_parses parser, with: "6", remaining: "", matched: "6"
      assert_parses parser, with: "",  remaining: "", matched: ""
    end

    it "works with multiple branches" do
      parser = Grammar.build do
        rule(:letter)         { many1 { anyLetter } }
        rule(:number)         { many1 { anyNumber } }
        rule(:letterOrNumber) { rule(:letter) | rule(:number) | eof }
        start(:letterOrNumber)
      end

      assert_parses parser, with: "n", remaining: "", matched: "n"
      assert_parses parser, with: "6", remaining: "", matched: "6"
      assert_parses parser, with: "",  remaining: "", matched: ""
    end

    it "works with satisfy" do
      parser = Grammar.build do
        rule(:letter)    { many1 { anyLetter } }
        rule(:letterOr1) { rule(:letter) | (satisfy { |input| input == "1" ? ok(matched: "1", remaining: "") : fail(input) }) }
        start(:letterOr1)
      end

      assert_parses parser, with: "n", remaining: ""
      assert_parses parser, with: "1", remaining: ""
    end
  end

  describe ">>" do
    it "works with a single branch" do
      parser = Grammar.build do
        rule(:letter)          { many1 { anyLetter } }
        rule(:number)          { many0 { anyNumber } }
        rule(:letterAndNumber) { rule(:letter) >> rule(:number) }
        start(:letterAndNumber)
      end

      assert_parses parser, with: "foo123", remaining: "", matched: "foo123"
    end

    it "works with multiple branches" do
      parser = Grammar.build do
        rule(:letter) { many1 { anyLetter } }
        rule(:number) { many0 { anyNumber } }
        rule(:foo)    { rule(:letter) >> rule(:number) >> rule(:letter) }
        start(:foo)
      end

      assert_parses parser, with: "foo123asd", remaining: "", matched: "foo123asd"
      assert_parses parser, with: "foo123",    remaining: "foo123", should_fail: true
    end

    it "works with rules and satisfies" do
      parser = Grammar.build do
        rule(:letter)          { many1 { anyLetter } }
        rule(:letterAndNumber) { rule(:letter) >> many0 { anyNumber } }
        start(:letterAndNumber)
      end

      assert_parses parser, with: "foo123", remaining: ""
      assert_parses parser, with: "foo",    remaining: ""
      assert_parses parser, with: "123a",   remaining: "123a", should_fail: true
    end
  end

  describe ">" do
    it "works with a single branch" do
      parser = Grammar.build do
        rule(:letter) { many1 { anyLetter } }
        rule(:foo)    { (rule :letter) > whitespace }
        start(:foo)
      end

      assert_parses parser, with: "foo   ", remaining: "", matched: "foo   "
    end
  end

  describe "<" do
    it "works with a single branch" do
      parser = Grammar.build do
        rule(:letter) { many1 { anyLetter } }
        rule(:foo)    { whitespace < (rule :letter) }
        start(:foo)
      end

      assert_parses parser, with: "   foo", remaining: "", matched: "   foo"
    end
  end

  describe ">=" do
    it "works with a single branch" do
      parser = Grammar.build do
        rule(:letter) { many1 { anyLetter } }
        rule(:foo)    { (rule :letter) >= whitespace }
        start(:foo)
      end

      assert_parses parser, with: "foo   ", remaining: "", matched: "foo"
    end
  end

  describe "<=" do
    it "matches second, first is ignored but consumed" do
      parser = Grammar.build do
        rule(:letter) { many1 { anyLetter } }
        rule(:foo)    { whitespace <= (rule :letter) }
        start(:foo)
      end

      assert_parses parser, with: "   foo", remaining: "", matched: "foo"
    end
  end
end
