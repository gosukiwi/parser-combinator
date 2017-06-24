class ParserResult
  attr_reader :success, :remaining
  def initialize(success, remaining)
    @success   = success
    @remaining = remaining
  end

  def self.ok
    ParserResult.new(true, "")
  end

  def self.fail(remaining)
    ParserResult.new(false, remaining)
  end

  def self.from_result(success:, consumed:, input:)
    remaining = success ? input[consumed..-1] : input
    ParserResult.new(success, remaining)
  end

  def ==(other)
    return other.success == success && other.remaining == remaining
  end
end
