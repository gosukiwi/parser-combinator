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
    nameAndEquals = match name and: equals

    # `match:or`
    nameOrEquals = match name or: equals

    # `match:between`
    betweenQuotes = match name between: (one '"') and: (one '"')

    # `seq` matches many parsers, and passes the result to a lambda
    assign = seq name equals name { |name _ value| Assign.new(lhs: name, rhs: value) }

    assign "hello123" # => (True, <AssignNode>)

## Running tests

    ruby -Ilib:test test/minitest/test_minitest_test.rb
