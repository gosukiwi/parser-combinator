require_relative "match_and_or_between"

module Combinators
  include MatchAndOrBetween

  def one(char)
    lambda do |input|
      input[0] == char
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

  def many1(&parser)
    lambda do |input|
      matched = false
      buffer  = input
      while parser.call(buffer) && !buffer.nil?
        matched = true
        buffer  = buffer[1..-1]
      end
      matched
    end
  end

  def many0(&parser)
    lambda do |input|
      return true if input.nil? || input == ""
      many1(&parser).call(input)
    end
  end

  def match(options)
    lambda do |input|
      match_from_options(options, input)
    end
  end

  #def seq(*args, &block)
  #  lambda do |input|
  #    new_args = args.map { |parser| parser.call(input) }
  #  end
  #end

  private

  def test(regex:, with:)
    !regex.match(with).nil?
  end
end
