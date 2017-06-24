require "minitest/autorun"
require "pry"
require_relative "spec_helpers"

# Build a grammar parsing JSON.
describe Grammar do
  it "parses JSON" do
    parser = Grammar.build do
      # Here `>` means right hand size is optional. `<` means left size is
      # optional.
      # You can think of `>` and `<` as an open duck mouth, the duck eats the
      # mandatory part, ignores the other. #PrimarySchoolHacks
      rule(:bopen)      { (one "{") > whitespace }
      rule(:bclose)     { whitespace < (one "}") }
      rule(:semicolon)  { whitespace < (one ":") > whitespace }
      rule(:comma)      { one "," }
      rule(:quote)      { one '"' }
      rule(:true)       { str "true" }
      rule(:false)      { str "false" }
      rule(:null)       { str "null" }

      rule(:hexdigit)  { anyChar %w(0 1 2 3 4 5 6 7 8 9 a b c d e f) }
      rule(:hexdigits) { (one "u") >> (exactly(4) { rule(:hexdigit) }) }
      rule(:any_escaped_char) { (one "\\") >> ((anyChar ['"', '\\', '/', 'b', 'f', 'n', 'r', 't']) | rule(:hexdigits)) }
      rule(:any_but_quotes_and_backslash) { (anyCharBut ['"', '\\']) | rule(:any_escaped_char) }

      rule(:string_char) { rule(:any_but_quotes_and_backslash) }
      rule(:string)      { match (many0 { rule(:string_char) }), between: [rule(:quote), rule(:quote)] }
      rule(:number)      { many1 { anyNumber } }
      rule(:value)       { rule(:string) | rule(:number) | rule(:object) | rule(:true) | rule(:false) | rule(:null) }
      rule(:pair)        { rule(:string) >> rule(:semicolon) >> rule(:value) }
      rule(:pair_group)  { (rule(:pair) >> rule(:comma) >> rule(:pair_group)) | rule(:pair) | empty }
      rule(:object)      { match rule(:pair_group), between: [rule(:bopen), rule(:bclose)] }

      # The last rule is always the starting rule, but let's make things clear
      start(:object)
    end

    test_parser parser, with: '{}'
    test_parser parser, with: '{ "foo": 123 }'
    test_parser parser, with: '{ "foo": false,"bar" : true }'
    test_parser parser, with: '{ "foo":{ "bar": "baz\\u1235" } }'
    test_parser parser, with: '{ "foo":{ "bar": "baz\\u125" } }', should_fail: true
  end
end
