require "minitest/autorun"
require "pry"
require_relative "spec_helpers"

# Build a grammar parsing JSON.
describe Grammar do
  it "step 1" do
    parser = Grammar.build do
      rule(:assign) { many1 { anyLetter } >> (str " = ") >> anyNumber }

      start(:assign)
    end

    parser.run("foo = 1").ok?.must_equal true
    parser.run("bar = 3").ok?.must_equal true
    parser.run("baz = 9").ok?.must_equal true
  end

  it "step 2" do
    parser = Grammar.build do
      rule(:equals) { whitespace < (one "=") > whitespace }
      rule(:assign) { many1 { anyLetter } >> (rule :equals) >> anyNumber }

      start(:assign)
    end

    parser.run("foo = 1").ok?.must_equal true
    parser.run("bar =3").ok?.must_equal  true
    parser.run("baz= 9").ok?.must_equal  true
  end
end
