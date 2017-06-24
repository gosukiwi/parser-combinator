require_relative "match_and_or_between"
require_relative "parser_result"

module Combinators
  include MatchAndOrBetween

  def one(char)
    lambda do |input|
      result = input[0] == char
      ParserResult.from_result(success: result, consumed: 1, input: input, matched: char)
    end
  end

  def anyLetter
    lambda do |input|
      matched, consumed = test regex: /^[a-zA-Z]/, with: input
      ParserResult.from_result(success: consumed > 0, consumed: consumed, input: input, matched: matched)
    end
  end

  def anyNumber
    lambda do |input|
      matched, consumed = test regex: /^[0-9]/, with: input
      ParserResult.from_result(success: consumed > 0, consumed: consumed, input: input, matched: matched)
    end
  end

  def many1(&wrapper)
    lambda do |input|
      matched   = ""
      remaining = input
      parser    = wrapper.call

      loop do
        result = parser.call(remaining)
        break if remaining.nil? || !result.success
        matched   = matched + result.matched
        remaining = result.remaining
      end

      ParserResult.new(!matched.empty?, remaining, matched)
    end
  end

  def many0(&wrapper)
    lambda do |input|
      return ParserResult.ok if input.nil? || input == ""
      many1(&wrapper).call(input)
    end
  end

  def match(options)
    lambda do |input|
      match_from_options(options, input)
    end
  end

  def seq(*args)
    callback  = args[-1]
    arguments = args[0..(args.length - 2)]

    raise "Seq expects at least a parser and a callback." if callback.nil? || arguments.empty?

    lambda do |input|
      remaining = input
      matched   = ""
      new_args  = arguments.map do |parser|
        result = parser.call(remaining)
        return ParserResult.fail(input) unless result.success
        remaining = result.remaining
        result.matched
      end

      callback.call(*new_args)
    end
  end

  private

  def test(regex:, with:)
    match = regex.match(with)
    match.nil? ? ["", 0] : [match[0], match[0].length]
  end
end
