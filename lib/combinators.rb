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
end
