require "minitest/autorun"
require "pry"
require_relative "spec_helpers"

# Build a grammar parsing JSON.
describe Grammar do
  it "parses JSON" do
    parser = Grammar.build do
      # =======================================================================
      # Here `>` means right hand size is optional. `<` means left size is
      # optional.
      # You can think of `>` and `<` as an open duck mouth, the duck eats the
      # mandatory part, ignores the other. #PrimarySchoolHacks
      #
      # `>>` means "and then" and `|` means "or else try this".
      #
      # Something similar happens with `>=` and `<=`, see `README.md` for more
      # info on binary combinators.
      # =======================================================================

      # Simple stuff
      rule(:bopen)       { (one "{") > whitespace }
      rule(:bclose)      { whitespace < (one "}") }
      rule(:semicolon)   { whitespace < (one ":") > whitespace }
      rule(:comma)       { whitespace < (one ",") > whitespace }
      rule(:quote)       { one '"' }
      rule(:true)        { str "true" }
      rule(:false)       { str "false" }
      rule(:null)        { str "null" }

      # string
      rule(:hexdigit)           { anyChar %w[0 1 2 3 4 5 6 7 8 9 a b c d e f] }
      rule(:hexdigits)          { (one "u") >> (exactly(4) { (rule :hexdigit) }) }
      rule(:any_escaped_char)   { (one "\\") >> ((anyChar %w[" \\ / b f n r t]) | (rule :hexdigits)) }
      rule(:any_unescaped_char) { (anyCharBut %w[" \\]) }
      rule(:string_char)        { (rule :any_unescaped_char) | (rule :any_escaped_char) }
      rule(:string)             { match (many0 { (rule :string_char) }), between: [(rule :quote), (rule :quote)] }

      # number
      rule(:decimal)              { (one '.') >> many1 { anyNumber } }
      rule(:cientific)            { (anyChar %w[e E]) >> (anyChar %w[+ -]) >> many1 { anyNumber } }
      rule(:decimal_or_cientific) { (rule :decimal) > (rule :cientific) }
      rule(:positive_number)      { ((one "0") | many1 { anyNumber }) > (rule :decimal_or_cientific) }
      rule(:number)               { (one "-") < (rule :positive_number) }

      # array
      rule(:array_body) { ((rule :value) >> (rule :comma) >> (rule :array_body)) | (rule :value) | empty }
      rule(:array)      { match (rule :array_body), between: [(one "["), (one "]")] }

      # other stuff
      rule(:value)       { (rule :string) | (rule :number) | (rule :object) | (rule :array) | (rule :true) | (rule :false) | (rule :null) }
      rule(:pair)        { (rule :string) >> (rule :semicolon) >> (rule :value) }
      rule(:pair_group)  { ((rule :pair) >> (rule :comma) >> (rule :pair_group)) | (rule :pair) | empty }
      rule(:object)      { match (rule :pair_group), between: [(rule :bopen), (rule :bclose)] }

      # The last rule is always the starting rule, but let's make things clear
      start(:object)
    end

    test_parser parser, with: '{}'
    test_parser parser, with: '{ "foo": 123 }'
    test_parser parser, with: '{ "foo": 0.321 }'
    test_parser parser, with: '{ "foo": 1.5 }'
    test_parser parser, with: '{ "foo": 1.5e-5 }'
    test_parser parser, with: '{ "foo": false,"b\\nar" : true }'
    test_parser parser, with: '{ "foo":{ "bar": "baz\\u1235" } }'
    test_parser parser, with: '{ "foo":{ "bar": "baz\\u125" } }', should_fail: true
    test_parser parser, with: '{ "foo": [] }'
    test_parser parser, with: '{ "foo": [1] }'
    test_parser parser, with: '{ "foo": [1, 2, 3, 4] }'
    test_parser parser, with: '{ "foo": [1, 2, 3, 4,] }' # TODO: fix this
    test_parser parser, with: '{ "foo": 123, }'          # TODO: and this
  end
end
