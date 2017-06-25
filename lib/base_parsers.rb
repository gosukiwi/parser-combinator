require_relative "parser_result"

module BaseParsers
  def eof
    Parser.new do |input|
      if input == "" || input.nil?
        ParserResult.ok(matched: "", remaining: input)
      else
        ParserResult.fail(input)
      end
    end
  end

  def empty
    Parser.new do |input|
      ParserResult.ok(matched: "", remaining: input)
    end
  end

  def whitespace
    Parser.new do |input|
      test regex: /^[ \n\t]+/, with: input
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

  def str(string)
    Parser.new do |input|
      if input.start_with?(string)
        ParserResult.ok(matched: string, remaining: input[string.length..-1])
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
        break if remaining.nil? || result.fail?
        matched   = matched + result.matched
        remaining = result.remaining
      end

      ParserResult.new(!matched.empty?, remaining, matched)
    end
  end

  def many0(&wrapper)
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

      new_args = parsers.map do |parser|
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

  def anyChar(chars)
    Parser.new do |input|
      first_char = input[0]
      result     = ParserResult.fail(input)

      chars.each do |char|
        if first_char == char
          result = ParserResult.ok(matched: char, remaining: input[1..-1])
          break
        end
      end

      result
    end
  end

  def anyCharBut(chars)
    Parser.new do |input|
      first_char = input[0]
      result     = ParserResult.ok(matched: first_char, remaining: input[1..-1])

      chars.each do |char|
        if first_char == char
          result = ParserResult.fail(input)
          break
        end
      end

      result
    end
  end

  def exactly(n, &wrapper)
    parser = wrapper.call
    Parser.new do |input|
      matched   = ""
      remaining = input
      success   = true

      n.to_i.times do
        result = parser.run(remaining)
        if result.fail?
          success = false
          break
        end
        matched   = matched + result.matched
        remaining = result.remaining
      end

      if success
        ParserResult.ok(matched: matched, remaining: remaining)
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
