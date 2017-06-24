require_relative "combinators"
require_relative "parser"

class Grammar
  class << self
    include Combinators

    def build(&block)
      raise "Must provide a block" unless block_given?
      @rules = {}
      instance_eval &block
    end

    def rule(name, &wrapper)
      return @rules.fetch(name.to_sym) { raise "Invalid rule: #{name}"} if wrapper.nil?
      @rules[name.to_sym] = Parser.new { |input| wrapper.call.run(input) }
    end

    def start(name)
      @rules[name]
    end
  end
end
