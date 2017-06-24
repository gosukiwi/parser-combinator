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
      if first.ok?
        second = other.run(first.remaining)
        if second.ok?
          second
        else
          ParserResult.fail(input)
        end
      else
        first
      end
    end
  end
end
