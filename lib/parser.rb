require_relative "combinators"

class Parser
  class << self
    include Combinators

    def build(&block)
      @rules = {}
      result = instance_eval &block
      result.call
    end

    def rule(name, &parser)
      return @rules.fetch(name.to_sym) { raise "Invalid rule: #{name}"} if parser.nil?
      @rules[name.to_sym] = parser
    end

    def start(name)
      @rules[name]
    end
  end
end
