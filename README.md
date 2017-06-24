# Parser Combinator
This library provides a DSL which you can use to easily generate parsers in
Ruby.

At it's core, it's a parser combinator library, but you don't need to worry
about that. You build more complex expression based on simple ones, and match
any formal language you want.

Here's an example:

# Documentation
The library provides several base `parsers` for you. Those are used to constuct
bigger, more complex parsers.

The documentation is a WIP, and reflects the actual API as much as possible, the
real and always updated API lives in the tests, so it's highly recommended
to check them out. Tests can be found in `test/test_*.rb`.

## Nothing
It simple matches nothing:

    parser = Grammar.build do
      let(:nothing) { nothing }
      start(:nothing)
    end

    parser.run("").ok?    # => true
    parser.run("foo").ok? # => false

# Development

    $ bundle install

## Parsers
A parser is an instance of `Parser`, an object with a `run` method which takes
some input and returns a `ParserResult`.

## Running tests

    $ ruby -Ilib:test test/test_parser.rb
