require_relative "parser_result"

module BaseParsers
  def nothing
    Parser.new do |input|
      if input == "" || input.nil?
        ParserResult.ok(matched: "", remaining: input)
      else
        ParserResult.fail(input)
      end
    end
  end

  def one(char)
    Parser.new do |input|
      if input[0] == char
        ParserResult.ok(matched: char, remaining: input[1..-1])
      else
        ParserResult.fail(input)
      end
    end
  end

  def anyLetter
    Parser.new do |input|
      test regex: /^[a-zA-Z]/, with: input
    end
  end

  def anyNumber
    Parser.new do |input|
      test regex: /^[0-9]/, with: input
    end
  end

  def many1(&wrapper)
    Parser.new do |input|
      matched   = ""
      remaining = input
      parser    = wrapper.call

      loop do
        result = parser.run(remaining)
        break if remaining.nil? || !result.success
        matched   = matched + result.matched
        remaining = result.remaining
      end

      ParserResult.new(!matched.empty?, remaining, matched)
    end
  end

  def many0(&wrapper)
    #Parser.new do |input|
    #  nothing | many1(&wrapper)
    #end
    Parser.new do |input|
      if input.nil? || input == ""
        ParserResult.ok(matched: "", remaining: input)
      else
        many1(&wrapper).run(input)
      end
    end
  end

  def seq(*args)
    callback = args[-1]
    parsers  = args[0..(args.length - 2)]

    raise "Seq expects at least a parser and a callback." if callback.nil? || parsers.empty?

    Parser.new do |input|
      remaining = input
      matched   = ""
      new_args  = parsers.map do |parser|
        result = parser.run(remaining)
        return ParserResult.fail(input) unless result.ok?
        remaining = result.remaining
        result.matched
      end

      callback.call(*new_args)
    end
  end

  # This is just an alias of lambda in the DSL. See specs for more on this.
  #
  def satisfy(&wrapper)
    Parser.new do |input|
      wrapper.call(input)
    end
  end

  def regex(re)
    Parser.new do |input|
      test regex: re, with: input
    end
  end

  # Match something in between some other parsers.
  # Usage:
  #   Grammar.build do
  #     rule(:quote) { one '"' }
  #     rule(:foo)   { match (many1 { anyLetter }), between: [rule(:quote), rule(:quote)] }
  #   end
  #
  # The grammar above will match 1+ letters between quotes, eg: "foo", "f", "HelloWorld".
  #
  def match(rule, between:)
    first, last = between
    Parser.new do |input|
      lhs = first.run(input)
      if lhs.ok?
        middle = rule.run(lhs.remaining)
        if middle.ok?
          rhs = last.run(middle.remaining)
          if rhs.ok?
            rhs
          else
            ParserResult.fail(input)
          end
        else
          ParserResult.fail(input)
        end
      else
        ParserResult.fail(input)
      end
    end
  end

  private

  # Test against a simple regex, no groups. It would be possible to pass a callback
  # to the regex, in order to work with groups. #MAYBE #TODO
  def test(regex:, with:)
    match = regex.match(with)
    return ParserResult.fail(with) if match.nil?
    matched = match[0]
    ParserResult.ok(matched: matched, remaining: with[matched.length..-1])
  end
end
