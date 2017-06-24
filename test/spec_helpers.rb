def assert_parses(parser, with:, remaining:, matched: nil, should_fail: false)
  result = parser.run(with)
  assert_equal !should_fail,      result.success
  assert_equal remaining, result.remaining
  assert_equal matched,   result.matched unless matched.nil?
end

def test_parser(parser, with:, should_fail: false)
  assert_equal !should_fail, parser.run(with).success
end

# Require everything in `/lib`
Dir[File.join(File.dirname(__FILE__), '../lib/**/*.rb')].each { |f| require f }
