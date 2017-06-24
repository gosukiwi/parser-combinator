def assert_parses(parser, with:, remaining:)
  result = parser.run(with)
  assert_equal true,      result.success
  assert_equal remaining, result.remaining
end

def assert_doesnt_parse(parser, with:, remaining:)
  result = parser.run(with)
  assert_equal false,     result.success
  assert_equal remaining, result.remaining
end

# Require everything in `/lib`
Dir[File.join(File.dirname(__FILE__), '../lib/**/*.rb')].each { |f| require f }
