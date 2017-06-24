module Combinators
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
