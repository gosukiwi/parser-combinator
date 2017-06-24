class Parser
  attr_reader :parser
  def initialize(&block)
    @parser = block
  end

  def run(input)
    parser.call(input)
  end
end
