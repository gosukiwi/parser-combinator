# Combinators allow us to "combine" parsers together.
# For example: run this parser first, if it fails, run this other one
#              run this parser first, and then run this other parser
module Combinators
  # Logical OR.
  # Usage:
  #   myParser | otherParser
  #
  def |(other)
    Parser.new do |input|
      first = run(input)
      if first.ok?
        first
      else
        other.run(input)
      end
    end
  end

  # Logical AND.
  # Usage:
  #   myParser >> otherParser
  #
  def >>(other)
    Parser.new do |input|
      first = run(input)
      matched = ""
      if first.ok?
        matched = matched + first.matched
        second = other.run(first.remaining)
        if second.ok?
          matched = matched + second.matched
          ParserResult.ok(matched: matched, remaining: second.remaining)
        else
          ParserResult.fail(input)
        end
      else
        first
      end
    end
  end

  # Match this, other is optional
  def >(other)
    Parser.new do |input|
      first = run(input)
      matched = ""
      if first.ok?
        matched = first.matched
        second  = other.run(first.remaining)
        if second.ok?
          matched = matched + second.matched
          ParserResult.ok(matched: matched, remaining: second.remaining)
        else
          first
        end
      else
        ParserResult.fail(input)
      end
    end
  end

  # Match other, this is optional
  def <(other)
    Parser.new do |input|
      first     = run(input)
      matched   = ""
      remaining = input

      if first.ok?
        matched   = first.matched
        remaining = first.remaining
      end

      second = other.run(remaining)
      if second.ok?
        matched = matched + second.matched
        ParserResult.ok(matched: matched, remaining: second.remaining)
      else
        ParserResult.fail(input)
      end
    end
  end
end
