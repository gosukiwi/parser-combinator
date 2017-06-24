require_relative "base_parsers"
require_relative "parser"

# This is the main DSL interface. It builds up grammar rules and sets up the
# DSL.
#
class Grammar
  class << self
    include BaseParsers

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

    # Aliases for DSL
    def ok(*args)
      ParserResult.ok(*args)
    end

    def fail(*args)
      ParserResult.fail(*args)
    end
  end
end
