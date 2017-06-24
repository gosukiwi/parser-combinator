require_relative "match_and_or_between"
require_relative "parser_result"

module Combinators
  include MatchAndOrBetween

  def one(char)
    lambda do |input|
      if input[0] == char
        ParserResult.ok(matched: char, remaining: input[1..-1])
      else
        ParserResult.fail(remaining: input)
      end
    end
  end

  def anyLetter
    lambda do |input|
      test regex: /^[a-zA-Z]/, with: input
    end
  end

  def anyNumber
    lambda do |input|
      test regex: /^[0-9]/, with: input
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
      return ParserResult.ok(matched: "", remaining: input) if input.nil? || input == ""
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

  # This is just an alias of lambda in the DSL. See specs for more on this.
  #
  def satisfy(&predicate)
    lambda do |input|
      predicate.call(input)
    end
  end

  def regex(re)
    lambda do |input|
      test regex: re, with: input
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
