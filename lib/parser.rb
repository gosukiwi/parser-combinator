class Parser
  class << self
    def build(&block)
      @rules = {}
      result = instance_eval &block
      result.call
    end

    def rule(name, &block)
      @rules[name.to_sym] = block
    end

    def start(name)
      @rules[name]
    end

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

    private

    def test(regex:, with:)
      !regex.match(with).nil?
    end
  end
end
