class ParserResult
  attr_reader :success, :remaining, :matched
  def initialize(success, remaining, matched)
    @success   = success
    @remaining = remaining
    @matched   = matched
  end

  def self.ok
    ParserResult.new(true, "", "")
  end

  def self.fail(remaining)
    ParserResult.new(false, remaining, "")
  end

  def self.from_result(success:, consumed:, input:, matched:)
    remaining = success ? input[consumed..-1] : input
    ParserResult.new(success, remaining, matched)
  end

  def ==(other)
    return other.instance_of?(self.class) && other.success == success && other.remaining == remaining && other.matched == matched
  end
end
