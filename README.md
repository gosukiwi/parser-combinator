# Parser Combinator
This library provides a DSL which you can use to easily generate parsers in
Ruby.

At it's core, it's a parser combinator library, but you don't need to worry
about that. You build more complex expression based on simple ones, and match
any formal language you want.

Here's what the grammars look like, this demo will parse [JSON](http://www.json.org/):

```ruby
parser = Grammar.build do
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
  rule(:array_body) { (rule :value_group) | empty }
  rule(:array)      { match (rule :array_body), between: [(one "["), (one "]")] }

  rule(:value_group) { ((rule :value) >> (rule :comma) >> (rule :value_group)) | (rule :value)  }
  rule(:value)       { (rule :string) | (rule :number) | (rule :object) | (rule :array) | (rule :true) | (rule :false) | (rule :null) }
  rule(:pair)        { (rule :string) >> (rule :semicolon) >> (rule :value) }
  rule(:pair_group)  { ((rule :pair) >> (rule :comma) >> (rule :pair_group)) | (rule :pair) }
  rule(:pair_body)   { (rule :pair_group) | empty }
  rule(:object)      { match (rule :pair_body), between: [(rule :bopen), (rule :bclose)] }

  # The last rule is always the starting rule, but let's make things clear
  start(:object)
end

parser.run('{ "foo": "bar" }').ok? # => true
parser.run('{ "foo": }').ok?       # => false
parser.run('not even json').ok?    # => false
```

It might look a bit cryptic at first but the power combinators give us is
well worth the initial learning curve! Don't believe me? Let me show you.

## Introduction
Okay let's do this! I'll show you how to use this library and why it's awesome.
Let's say we want to match an assign statement:

```ruby
foo = 1
```

We can start right away!

```ruby
# this uses minitest, see `test/test_turorial.rb`
parser = Grammar.build do
  rule(:assign) { (str "foo = 1") }

  start(:assign)
end

parser.run("foo = 1").ok?.must_equal true
```

That was almost cheating wasn't it. Let's say we want to be able to match
any number now:

> **NOTE** That looks like RSpec doesn't it? Well it's what most Ruby DSLs look
> like, and if you've ever worked with any, you'll feel right at home. If not,
> don't worry a DSL is a tiny language afterall!

```ruby
parser = Grammar.build do
  rule(:assign) { (str "foo = ") >> anyNumber }

  start(:assign)
end

parser.run("foo = 1").ok?.must_equal true
parser.run("foo = 3").ok?.must_equal true
parser.run("foo = 9").ok?.must_equal true
```

It works! It really is that easy. But what is that `>>` thing over there? It
just means _"match this AND THEN match this other thing"_. If any of them fails,
the rule fails.

Okay now let's say we want real identifiers, not just `foo`:

```ruby
parser = Grammar.build do
  rule(:assign) { many1 { anyLetter } >> (str " = ") >> anyNumber }

  start(:assign)
end

parser.run("foo = 1").ok?.must_equal true
parser.run("bar = 3").ok?.must_equal true
parser.run("baz = 9").ok?.must_equal true
```

Oh! Almost too easy right? `many1` is a parser provided for you, it takes a
block. The block must return a parser which will be run on the input **one or
more times**. It's the same as saying `anyLetter+`.

We also use something called `anyLetter`. It is a parser provided by the library
and it matches `[a-zA-Z]+`.

> **NOTE** As you might have guessed, you are also provided of a parser called
> `many0`. `many0 { anyLetter }` is the equivalent of `anyLetter*`.

Now, let's tidy up the grammar a bit:

```ruby
parser = Grammar.build do
  rule(:equals) { whitespace < (one "=") > whitespace }
  rule(:assign) { many1 { anyLetter } >> (rule :equals) >> anyNumber }

  start(:assign)
end

parser.run("foo = 1").ok?.must_equal true
parser.run("bar =3").ok?.must_equal  true
parser.run("baz= 9").ok?.must_equal  true
```

Nice! What is `>` and `<` you ask? Well, they are similar to `>>`, and they are
called _combinators_. This is a parser combinator afterall right? That whole
concept is borrowed from functional programming, you don't really need it to use
the library at all though, so don't worry.

The combinator `>` means _"take whatever is on the left, and the right is optional"_. As you might
have guessed, `<` means the exact opposite, _"take whatever is on the right,
and the left is optional"_. We can combine those two in a hacky way to write

```ruby
whitespace < (one "=") > whitespace
```

You can think about it as _"surround (one "=") with optional stuff"_.

And that's it! Not bad for a 5 minutes intro huh?

# Documentation
The library provides several base `parsers` for you. Those are used to constuct
bigger, more complex parsers.

The documentation is a WIP, and reflects the actual API as much as possible, the
real and always updated API lives in the tests, so it's highly recommended
to check them out. Tests can be found in `test/test_*.rb`.

## Base Parsers

## Binary Combinators
### Logical OR: |

    let(:foo) { rule(:bar) | rule(:baz) }

### Logical AND: >>

    let(:foo) { rule(:bar) >> rule(:baz) }

## Unary Combinators
TODO
* and +

# Development

    $ bundle install

## Parsers
A parser is an instance of `Parser`, an object with a `run` method which takes
some input and returns a `ParserResult`.

## Running tests

    $ ruby -Ilib:test test/test_parser.rb

# TODO
Decent syntax error reporting, eg: Which line, which column failed.
