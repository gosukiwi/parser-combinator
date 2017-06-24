module MatchAndOrBetween
  # This is a complicated one... it divides match method into three:
  # Matching "and", "or", and "between".
  #
  def match_from_options(options, input)
    first = options.fetch(:first) { raise "Must always provide :first" }
    if options[:orElse]
      match_or first.call, options[:orElse].call, input
    else
      raise "Invalid match, expecting :andAlso, :orElse, :between:and."
    end
  end

  private

  def match_or(first, second, input)
    first.call(input) || second.call(input)
  end
end
