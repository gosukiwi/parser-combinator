class Parser
  attr_reader :parser
  def initialize(&block)
    raise "Invalid argument, must provide a block" unless block_given?
    @parser = block
  end

  def run(input)
    parser.call(input)
  end
end
