class ParserResult
  attr_reader :success, :remaining, :matched
  def initialize(success, remaining, matched)
    @success   = success
    @remaining = remaining
    @matched   = matched
  end

  def self.ok(matched:, remaining:)
    ParserResult.new(true, remaining, matched)
  end

  def self.fail(remaining)
    ParserResult.new(false, remaining, "")
  end

  def ok?
    success
  end

  def fail?
    success == false
  end

  def ==(other)
    return other.instance_of?(self.class) && other.success == success && other.remaining == remaining && other.matched == matched
  end
end
