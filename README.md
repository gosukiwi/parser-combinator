# Parser Combinator
In a Ruby, using a DSL

    # `many` takes a lambda, matches that multiple times
    many { [1, 2, 3] } # => <a lambda>

    # `many1`, one or more
    # `many0`, zero or more
    name = many0 { any { ['a'..'z'] } } # => <a lambda>

    # `one` matches a single char
    equals = one '='

    # `match:and` matches the first argument, and then the second. If any
    # of them fails, it fails.
    nameAndEquals = match first: name andThen: equals

    # `match:or`
    nameOrEquals = match first: name orElse: equals

    # `match:between`
    betweenQuotes = match first: name between: (one '"') and: (one '"')

    # `seq` matches many parsers, and passes the result to a lambda
    assign = seq name, equals, name, lambda { |name, _ , value| Assign.new(lhs: name, rhs: value) }

    assign "hello123" # => #<ParserResult>

## Running tests

    ruby -Ilib:test test/test_parser.rb
