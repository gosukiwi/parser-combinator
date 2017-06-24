module MatchAndOrBetween
  # This is a complicated one... it divides match method into three:
  # Matching "and", "or", and "between".
  #
  def match_from_options(options, input)
    first = options.fetch(:first) { raise "Must always provide :first" }
    if options[:orElse]
      match_or first, options[:orElse], input
    else
      raise "Invalid match, expecting :andAlso, :orElse, :between:and."
    end
  end

  private

  def match_or(first, second, input)
    f = first.run(input)
    return f if f.success
    second.run(input)
  end
end
