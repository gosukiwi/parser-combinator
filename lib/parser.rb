class Parser
  attr_reader :parser
  def initialize(&block)
    raise "Invalid argument, must provide a block" unless block_given?
    @parser = block
  end

  def run(input)
    parser.call(input)
  end

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
end
