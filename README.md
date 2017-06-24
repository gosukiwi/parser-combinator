# Parser Combinator
In a Ruby, using a DSL

    # `many` takes a lambda, matches that multiple times
    many { [1, 2, 3] } # => <a lambda>

    # `many1`, one or more
    # `many0`, zero or more
    name = many0 { any { ['a'..'z'] } } # => <a lambda>

    # `one` matches a single char
    equals = one '='

    # `match:between`
    betweenQuotes = match name between: (one '"') and: (one '"')

    # `seq` matches many parsers, and passes the result to a lambda
    assign = seq name, equals, name, lambda { |name, _ , value| Assign.new(lhs: name, rhs: value) }

    assign "hello123" # => #<ParserResult>

# Development

## Parsers
A parser is an instance of `Parser`, an object with a `run` method which takes
some input and returns a `ParserResult`.

## Running tests

    ruby -Ilib:test test/test_parser.rb
